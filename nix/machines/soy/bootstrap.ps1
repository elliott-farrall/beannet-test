$Wsl = @{
  Repo        = "https://github.com/nix-community/NixOS-WSL"
  Version     = "2511.7.1"
  File        = "$env:TEMP\nixos.wsl"
  Distro      = "NixOS"
  DefaultUser = "nixos"
  Hostname    = "nixos"
}

$Clan = @{
  Repo        = "https://github.com/elliott-farrall/beannet-test"
  Branch      = "dev"
  Shell       = "bean"
  Machine     = "soy"
  DefaultUser = "elliott"
}

$FlakeUrl = "$($Clan.Repo)/archive/refs/heads/$($Clan.Branch).tar.gz"

function Write-Header ([string]$Message) {
  $width = 48
  $line = "=" * $width
  Write-Host ""
  Write-Host $line -ForegroundColor DarkGray
  Write-Host "  $Message" -ForegroundColor White
  Write-Host $line -ForegroundColor DarkGray
  Write-Host ""
}

function Write-Step ([string]$Message) {
  Write-Host "  =>  $Message" -ForegroundColor Cyan
}

function Write-Info ([string]$Message) {
  Write-Host "       $Message" -ForegroundColor Gray
}

function Write-Ok ([string]$Message) {
  Write-Host "       $Message" -ForegroundColor Green
}

function Write-Err ([string]$Message) {
  Write-Host "  !!  $Message" -ForegroundColor Red
}

Write-Header "Bootstrap: $($Wsl.Distro) -> $($Clan.Machine)"

# Install NixOS WSL
Write-Step "Installing $($Wsl.Distro) WSL $($Wsl.Version)..."
wsl --shutdown | Out-Null
wsl --unregister $Wsl.Distro | Out-Null
Invoke-WebRequest -Uri "$($Wsl.Repo)/releases/download/$($Wsl.Version)/nixos.wsl" -OutFile $Wsl.File
wsl --install --no-launch --from-file $Wsl.File | Out-Null
Remove-Item $Wsl.File
Write-Ok "Distro registered"

# Resolve the target username
Write-Step "Resolving username..."
$Username = $Clan.DefaultUser
Write-Ok "Username: $Username"

# Generate a temporary SSH key pair for the bootstrap SSH connection
Write-Step "Generating bootstrap SSH key pair..."
wsl -d $Wsl.Distro -u root -e sh -c "mkdir -p /root/.ssh && ssh-keygen -t ed25519 -f /root/.ssh/bootstrap -N '' -q" | Out-Null
$SshPubKey = (wsl -d $Wsl.Distro -u root -e sh -c "cat /root/.ssh/bootstrap.pub").Trim()
if ($SshPubKey) {
  Write-Ok "Key: $($SshPubKey.Substring(0, [Math]::Min(48, $SshPubKey.Length)))..."
}
else {
  Write-Err "Failed to generate SSH key pair"
}

# Write bootstrap NixOS config
Write-Step "Writing bootstrap NixOS config..."
@"
{ config, pkgs, lib, ... }:

{
  imports = [ ./configuration.nix ];

  networking.interfaces."eth0".mtu = 1400;

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [ "$SshPubKey" ];

  wsl.defaultUser = lib.mkForce "$Username";
}
"@ | wsl -d $Wsl.Distro -u root -e sh -c "cat > /etc/nixos/bootstrap.nix" | Out-Null
Write-Ok "Written to /etc/nixos/bootstrap.nix"

# Apply bootstrap config and restart
Write-Step "Applying bootstrap config..."
wsl -d $Wsl.Distro -u root -e sh -c "nixos-rebuild boot -I nixos-config=/etc/nixos/bootstrap.nix" | Out-Null
Write-Ok "Rebuilt, restarting distro..."
wsl -t $Wsl.Distro | Out-Null
wsl -d $Wsl.Distro -u root exit | Out-Null
wsl -t $Wsl.Distro | Out-Null
Write-Ok "Distro restarted"

if ($Username -ne $Wsl.DefaultUser) {
  wsl -d $Wsl.Distro -u root -e sh -c "rm -rf /home/$($Wsl.DefaultUser)" | Out-Null
  Write-Info "Removed /home/$($Wsl.DefaultUser)"
}

# Install bootstrap SSH key and write SSH config for the bootstrap host
Write-Step "Installing bootstrap SSH key for $Username..."
wsl -d $Wsl.Distro -u root -e sh -c "install -D -m 600 -o $Username /root/.ssh/bootstrap /home/$Username/.ssh/bootstrap && chown $Username /home/$Username/.ssh && chmod 700 /home/$Username/.ssh" | Out-Null
@"
Host $($Wsl.Hostname)
  IdentityFile ~/.ssh/bootstrap
  StrictHostKeyChecking no
"@ | wsl -d $Wsl.Distro -u root -e sh -c "cat > /home/$Username/.ssh/config && chown $Username /home/$Username/.ssh/config && chmod 600 /home/$Username/.ssh/config" | Out-Null
Write-Ok "SSH key and config written to /home/$Username/.ssh/"

# Configure sops-age key
Write-Step "Configuring sops-age key..."
wsl -d $Wsl.Distro -e sh -c "mkdir -p ~/.config/sops/age" | Out-Null
Write-Host ""
$AgeKey = Read-Host -AsSecureString -Prompt "       AGE key"
Write-Host ""
"$(ConvertFrom-SecureString $AgeKey -AsPlainText)" | wsl -d $Wsl.Distro -e sh -c "cat > ~/.config/sops/age/keys.txt" | Out-Null

$AgeKeySize = wsl -d $Wsl.Distro -e sh -c "wc -c < ~/.config/sops/age/keys.txt 2>/dev/null"
if ([int]$AgeKeySize -gt 0) {
  Write-Ok "AGE key written ($AgeKeySize bytes)"
}
else {
  Write-Err "AGE key file is missing or empty — aborting"
  exit 1
}

# Run clan machines update using the bootstrap SSH key
Write-Step "Running clan machines update for $($Clan.Machine)..."
wsl -d $Wsl.Distro -e sh -c "nix develop --extra-experimental-features 'nix-command flakes' --accept-flake-config $FlakeUrl#$($Clan.Shell) --command sh -c 'clan machines update $($Clan.Machine) --target-host $($Wsl.Hostname) --host-key-check none --flake $FlakeUrl'"

if ($LASTEXITCODE -eq 0) {
  Write-Header "Bootstrap complete"
}
else {
  Write-Err "clan machines update failed (exit $LASTEXITCODE)"
}

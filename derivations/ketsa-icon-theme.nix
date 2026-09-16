# Ketsa icon theme by zayronxio; not in nixpkgs.
#   https://github.com/zayronxio/ketsa-icon-theme
#
# Upstream ships no build system: the repo root is the theme, copied wholesale
# Fixed up here: missing icon-theme.cache, devices/192 absent from `Directories=`,
# and Icons-Individuales/ (8 loose svgs) dropped
{ lib
, stdenvNoCC
, fetchFromGitHub
, gtk3
, kdePackages
, pantheon
, adwaita-icon-theme
}:

stdenvNoCC.mkDerivation {
  pname = "ketsa-icon-theme";
  version = "0-unstable-2023-01-10"; # upstream tags nothing; last commit

  src = fetchFromGitHub {
    owner = "zayronxio";
    repo = "ketsa-icon-theme";
    rev = "ed39fca155c189045ae27bb0249a0096ee93c4e7";
    hash = "sha256-X2O3JoKR4G1XYGEqQX8jhlL+M+GPadsYDHAL2UQst18=";
  };

  # gtk-update-icon-cache lives in gtk3
  nativeBuildInputs = [ gtk3 ];

  # index.theme's `Inherits=breeze,elementary,gnome,hicolor`
  propagatedBuildInputs = [
    kdePackages.breeze-icons
    pantheon.elementary-icon-theme
    adwaita-icon-theme # the "gnome" theme
  ];

  dontDropIconThemeCache = true; # built below

  dontWrapQtApps = true; # breeze-icons pulls in qt's setup hooks; icons only

  installPhase = ''
    runHook preInstall

    dir=$out/share/icons/ketsa
    mkdir -p "$dir"

    # the theme, minus the non-theme files and Icons-Individuales/
    cp -r index.theme apps devices mimetypes places "$dir"/

    # gtk only reads `Directories=`, so an unlisted devices/192 is invisible
    substituteInPlace "$dir/index.theme" \
      --replace-fail \
        'Directories=apps/64,places/64,places/16,mimetypes/128' \
        'Directories=apps/64,places/64,places/16,mimetypes/128,devices/192'

    # and its size section
    cat >> "$dir/index.theme" <<-'EOF'

	[devices/192]
	Size=192
	Context=Devices
	MinSize=16
	MaxSize=512
	Type=Scalable
	EOF

    gtk-update-icon-cache --force --quiet "$dir"

    runHook postInstall
  '';

  meta = {
    description = "Ketsa icon theme";
    homepage = "https://github.com/zayronxio/ketsa-icon-theme";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
}

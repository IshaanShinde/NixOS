# Ketsa icon theme by zayronxio.
#   https://github.com/zayronxio/ketsa-icon-theme
#   https://store.kde.org/p/1214846
#
# Not in nixpkgs. Upstream ships no build system: the repo root *is* the theme
# (index.theme sits beside apps/, places/, ...), so unlike a repo holding named
# theme directories, the whole source is copied into one `ketsa` directory here.
#
# Three things upstream leaves undone that this fixes up:
#   - no icon-theme.cache at all, generated at build time so lookups hit the
#     cache instead of walking ~1900 files
#   - index.theme's `Directories=` lists only four of the five icon dirs,
#     omitting devices/192; an unlisted directory is invisible to gtk, so its
#     icons (battery) never resolve. The line is rewritten to include it.
#   - Icons-Individuales/ is a loose pile of 8 svgs outside the theme layout
#     (no size directory, not in `Directories=`), so it is left out entirely
#
# index.theme declares `Inherits=breeze,elementary,gnome,hicolor`, so all three
# are propagated: the fork defines ~1900 icons and leans on them for the rest.
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

  # the themes ketsa inherits for everything it does not define
  propagatedBuildInputs = [
    kdePackages.breeze-icons
    pantheon.elementary-icon-theme
    adwaita-icon-theme # the "gnome" theme; adwaita carries its name
  ];

  dontDropIconThemeCache = true; # this derivation builds the cache itself

  # breeze-icons pulls in qt's setup hooks, which refuse to run unless the build
  # says what to do about wrapping; nothing here is a qt app, only icon files
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    dir=$out/share/icons/ketsa
    mkdir -p "$dir"

    # the repo root is the theme, minus the non-theme files and the loose pile
    cp -r index.theme apps devices mimetypes places "$dir"/

    # devices/192 holds icons but is missing from `Directories=`, which is the
    # only list gtk reads; without it the directory may as well not exist
    substituteInPlace "$dir/index.theme" \
      --replace-fail \
        'Directories=apps/64,places/64,places/16,mimetypes/128' \
        'Directories=apps/64,places/64,places/16,mimetypes/128,devices/192'

    # and the matching section describing that directory, which gtk needs to
    # know what size the icons in it are
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

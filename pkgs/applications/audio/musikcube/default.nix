{ asio
, cmake
, curl
, fetchFromGitHub
, fetchpatch
, ffmpeg
, gnutls
, lame
, lib
, libev
, game-music-emu
, libmicrohttpd
, libopenmpt
, mpg123
, ncurses
, pkg-config
, portaudio
, stdenv
, taglib
# Linux Dependencies
, alsa-lib
, pipewireSupport ? !stdenv.hostPlatform.isDarwin, pipewire
, pulseaudio
, sndioSupport ? true, sndio
, systemd
, systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd
# Darwin Dependencies
, Cocoa
, SystemConfiguration
, coreaudioSupport ? stdenv.hostPlatform.isDarwin, CoreAudio
}:

stdenv.mkDerivation rec {
  pname = "musikcube";
  version = "0.99.7";

  src = fetchFromGitHub {
    owner = "clangen";
    repo = pname;
    rev = version;
    sha256 = "sha256-bsvq48zTNafsQGFXVApCEWIL8H2RXiowalEu/W3DUu0=";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    asio
    curl
    ffmpeg
    gnutls
    lame
    libev
    game-music-emu
    libmicrohttpd
    libopenmpt
    mpg123
    ncurses
    portaudio
    taglib
  ] ++ lib.optionals systemdSupport [
    systemd
  ] ++ lib.optionals stdenv.isLinux [
    alsa-lib pulseaudio
  ] ++ lib.optionals stdenv.isDarwin [
    Cocoa SystemConfiguration
  ] ++ lib.optionals coreaudioSupport [
    CoreAudio
  ] ++ lib.optionals sndioSupport [
    sndio
  ] ++ lib.optionals pipewireSupport [
    pipewire
  ];

  cmakeFlags = [
    "-DDISABLE_STRIP=true"
  ];

  postFixup = lib.optionalString stdenv.isDarwin ''
    install_name_tool -add_rpath $out/share/${pname} $out/share/${pname}/${pname}
    install_name_tool -add_rpath $out/share/${pname} $out/share/${pname}/${pname}d
  '';

  meta = with lib; {
    description = "A fully functional terminal-based music player, library, and streaming audio server";
    homepage = "https://musikcube.com/";
    maintainers = with maintainers; [ aanderse srapenne ];
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}

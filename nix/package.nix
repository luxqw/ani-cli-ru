{
  lib,
  pkgs,
  callPackage,
  buildPythonApplication,
  # runtime binary.
  # NB: not named `mpv` on purpose - inside `python3Packages` that name is taken
  # by the python-mpv binding (a library with no `bin/`), and callPackage would
  # inject it over this default
  mpvPlayer ? pkgs.mpv,
  # build-system
  hatchling,
  # dependencies
  prompt-toolkit,
  rich,
  typer,
  # web extra
  fastapi,
  jinja2,
  python-multipart,
  segno,
  uvicorn,
  #
  anicli-api ? callPackage ./api.nix { },
  src ? lib.cleanSource ../.,
}:

# watch anime in terminal (cli)
# only russian sources

buildPythonApplication {
  pname = "anicli-ru";
  version = "6.1.3";
  pyproject = true;

  inherit src;

  build-system = [ hatchling ];

  dependencies = [
    anicli-api
    prompt-toolkit
    rich
    typer
    # web extra
    fastapi
    jinja2
    python-multipart
    segno
    uvicorn
  ];

  # the `cli` command spawns mpv via shutil.which, so it has to be on PATH
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ mpvPlayer ])
  ];

  pythonImportsCheck = [
    "anicli"
    "anicli.web.server"
  ];

  meta = {
    description = "Watch anime in terminal (only russian sources)";
    homepage = "https://github.com/vypivshiy/ani-cli-ru";
    # the shipped LICENSE file and the README both say GPL-3.0;
    # `license = "MIT"` in pyproject.toml contradicts them
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ ch4og ];
    mainProgram = "anicli-ru";
  };
}

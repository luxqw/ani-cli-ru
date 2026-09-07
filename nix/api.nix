{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  # build-system
  hatchling,
  # dependencies
  attrs,
  cssselect,
  httpx,
  lxml,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "anicli_api";
  version = "0.9.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8EKpLK04SgP3Xn8ZK82+0Dewwen/xYiDEeGozkYdhv8=";
  };

  build-system = [ hatchling ];

  dependencies =
    [
      attrs
      cssselect
      httpx
      lxml
    ]
    ++ httpx.optional-dependencies.brotli
    ++ httpx.optional-dependencies.http2
    ++ httpx.optional-dependencies.socks
    ++ lib.optionals (pythonOlder "3.11") [ typing-extensions ];

  pythonImportsCheck = [ "anicli_api" ];

  meta = {
    description = "Anime extractors api implementation";
    homepage = "https://github.com/vypivshiy/anicli-api";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}

:- [load].
:- doc_server(4000,
              [ allow('.my.org')
              ]).
:- use_module(library(pldoc/doc_library)).
:- doc_load_library.
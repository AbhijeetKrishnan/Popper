:- use_module(src/board).
:- use_module(src/make_move).
:- use_module(src/tactics).

:- unload_file(debug).
:- unload_file(load).
:- set_prolog_flag(answer_write_options, [max_depth(0)]). % https://stackoverflow.com/a/36948699
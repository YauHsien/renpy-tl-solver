tl(File) :-
    csv_read_file(File, Rows, [separator(0),convert(false),match_arity(false)]),
    translate(Rows, Results),
    %
    File1 = File,
    open(File1, write, Fstream, [bom(true)]),
    foreach(member(row(R),Results), writeln(Fstream,R)).

translate(Rows, Results) :-
    length(Rows, L),
    translate(Rows, L, L, [], Results).

translate([], _Total, _Count, Acc, Results) :-
    % 這裡最後走完翻譯行程了。
    reverse(Acc, Results).
translate([row(Atom)|Rows], Total, Count, Acc, Results) :-
    prog(Atom, Result), !,
    % 這裡是往下繼續翻譯行程。
    C1 is Count-1,
    format('~`0t ~2f~4| ~a~n', [(Total-C1)/Total*100,Result]),
    translate(Rows, Total, C1, [Result|Acc], Results).
translate(Rows, _Total, _Count, Acc, Results) :-
    % 這裡處理終止翻譯行程的手續。
    reverse(Acc, R0),
    enfunc(R0, R1),
    append(R1, Rows, Results).

prog(Atom, Result) :-
    atomic_list_concat([A,B], '""', Atom), !,
    prompt1('翻譯：'),
    read_line_to_string(user_input, Input),
    "" \= Input,
    atomic_list_concat([A,'"',Input,'"',B], '', Result).
prog(Atom, Atom).

enfunc([], []).
enfunc([Line|Rows], [row(Line)|Results]) :-
    enfunc(Rows, Results).

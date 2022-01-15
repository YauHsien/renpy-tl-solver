tl(File) :-
    csv_read_file(File, Rows, [separator(0),convert(false),match_arity(false)]),
    count(Rows, _All, Total, Count),
    translate(Total, Count, Rows, Results),
    %
    File1 = File,
    open(File1, write, Fstream, [bom(true)]),
    foreach(member(row(R),Results), writeln(Fstream,R)).

count(Rows, All, Total, Count) :-
    count(Rows, 0, 0, 0, All, Total, Count).

count([], All, Total, Count, All, Total, Count).
count([row(Line)|Rows], AccA, AccT, AccC, All, Total, Count) :-
    atomic_list_concat([_,X,_], '"', Line), !,
    (
        '' = X, !,
        A is AccA+1,
        T is AccT+1,
        count(Rows, A, T, AccC, All, Total, Count)
    ;   %
        A is AccA+1,
        T is AccT+1,
        C is AccC+1,
        count(Rows, A, T, C, All, Total, Count)
    ).
count([_|Rows], AccA, AccT, AccC, All, Total, Count) :-
    A is AccA+1,
    count(Rows, A, AccT, AccC, All, Total, Count).

translate(Total, Count, Rows, Results) :-
    translate(Total, Count, Rows, [], Results).

translate(_Total, _Count, [], Acc, Results) :-
    % 這裡最後走完翻譯行程了。
    reverse(Acc, Results).
translate(Total, Count, [row(Atom)|Rows], Acc, Results) :-
    prog(Count, Atom, Result, C1), !,
    % 這裡是往下繼續翻譯行程。
    format('~`0t ~2f~4| ~a~n', [(Total-C1)/Total*100,Result]),
    translate(Total, C1, Rows, [Result|Acc], Results).
translate(_Total, _Count, Rows, Acc, Results) :-
    % 這裡處理終止翻譯行程的手續。
    reverse(Acc, R0),
    enfunc(R0, R1),
    append(R1, Rows, Results).

prog(Count, Atom, Result, Count1) :-
    atomic_list_concat([A,B], '""', Atom), !,
    Count1 is Count-1,
    prompt1('翻譯：'),
    read_line_to_string(user_input, Input),
    "" \= Input,
    atomic_list_concat([A,'"',Input,'"',B], '', Result).
prog(Count, Atom, Atom, Count).

enfunc([], []).
enfunc([Line|Rows], [row(Line)|Results]) :-
    enfunc(Rows, Results).

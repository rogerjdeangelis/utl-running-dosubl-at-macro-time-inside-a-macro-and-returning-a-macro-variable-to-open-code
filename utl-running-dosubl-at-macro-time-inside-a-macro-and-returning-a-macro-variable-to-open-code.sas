%let pgm=utl-running-dosubl-at-macro-time-inside-a-macro-and-returning-a-macro-variable-to-open-code;

%stop_submission;

Academic exercise

Until now I have not been able to run dosubl inside a macro and
return the result to open code;

This needs a little more QC but appears to work

Running dosubl at macro time inside at macro returning a macro variable to open code;
This suppors macros that can contain dosubl and return macro variables to open code
all at macro time.

 Problem

   1 Clarification by Quentin McMullen
     qcmullen.sas@gmail.com Quentin McMullen

   2 Create a dynamic array inside a datastep (sort of)


github
https://tinyurl.com/mrynuher
https://github.com/rogerjdeangelis/utl-running-dosubl-at-macro-time-inside-a-macro-and-returning-a-macro-variable-to-open-code


RELATED INTERFACES

https://github.com/rogerjdeangelis/utl_dosubl_subroutine_interfaces
https://github.com/rogerjdeangelis/utl-potentially-useful-dosubl-interface
https://github.com/rogerjdeangelis/utl-twelve-interfaces-for-dosubl

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/**************************************************************************************************************************/
/*                                |                                           |                                           */
/*          INPUT                 |               PROCESS                     |                OUTPUT                     */
/*                                |                                           |                                           */
/* 1 CLARIFICATION QUENTIN        |                                           |                                           */
/* =======================        |                                           |                                           */
/*                                |                                           |                                           */
/* In my                          | %macro dynLvl(dsn,var);                   |         <<19>>                            */
/* experience when you use DOSUBL |                                           |                                           */
/* inside a macro, any global     |  %***global foo;                          |                                           */
/* macro variable created         |                                           |                                           */
/* in the dosubl side-session     |  %let rc=                                 |                                           */
/* will be returned as a main     |   %sysfunc(dosubl(%nrstr(                 |                                           */
/* session global macro variable, |   proc sql noprint;                       |                                           */
/* unless you are careful         |     select                                |                                           */
/* to define it in the main       |       count(distinct &var)                |                                           */
/* session as %local.  So below,  |     into                                  |                                           */
/* even though I commented        |       :foo trimmed                        |                                           */
/* out the %GLOBAL statement, the |     from                                  |                                           */
/* macro variable FOO is          |       &dsn                                |                                           */
/* still returned to              |   ;quit;                                  |                                           */
/* the main session global s      |  ))) ;                                    |                                           */
/* ymbol table.                   |                                           |                                           */
/*                                |   &foo                                    |                                           */
/*                                |                                           |                                           */
/* So I've always found it        |  %mend dynLvl;                            |                                           */
/* easy to return dosubl          |                                           |                                           */
/*  macro vars to the main        |  %symdel foo /nowarn;                     |                                           */
/* session global                 |  %put                                     |                                           */
/* symbol table, and in           |   %dynLvl(sashelp.class,name);            |                                           */
/* situations like above          |  %put _user_ ;                            |                                           */
/* I find it to be                |                                           |                                           */
/* *too* easy.                    |                                           |                                           */
/* I wish Rick had decided        |                                           |                                           */
/* to make                        |                                           |                                           */
/* the above create a             |                                           |                                           */
/* %local macro variable.         |                                           |                                           */
/* But such is life.              |                                           |                                           */
/*                                |                                           |                                           */
/*------------------------------------------------------------------------------------------------------------------------*/
/*                                |                                           |                                           */
/* 2 CREATE A DYNAMIC ARRAY       |                                           |                                           */
/* =======================        |                                           |                                           */
/*                                |                                           |                                           */
/* Data have;                     | data want(drop=month sum lunch);          | WORK.WANT total obs=1                     */
/* input Month $ @@;              |                                           |                                           */
/* lunch=int(10*uniform(1232)+30);|   array mon                               | MON1 MON2 MON3 MON4 MON5 MON6 MON7 MON8   */
/* cards;                         |       mon1-mon%left(%dynLvl(have,month)); |                                           */
/* month1 month1 month2           |                                           |  69   70   34   100  63   34   165  77    */
/* month2 month3 month4           |   set have end=dne;                       |                                           */
/* month4 month4 month5           |   by month;                               |                                           */
/* month5 month6 month7           |                                           |                                           */
/* month7 month7 month7           |   retain idx sum                          |                                           */
/* month7 month8 month8           |      mon1-mon%left(%dynLvl(have,month)) 0 |                                           */
/* ;;;;                           |                                           |                                           */
/* run;quit;                      |   sum = ifn(first.month,lunch,sum+lunch); |                                           */
/*                                |                                           |                                           */
/*                                |   if last.month then do;                  |                                           */
/*  HAVE total obs=18             |     idx=idx+1;                            |                                           */
/*                                |      mon[idx] = sum;                      |                                           */
/*  Obs   MONTH     LUNCH         |   end;                                    |                                           */
/*                                |                                           |                                           */
/*   1    month1      38          |   if dne then output;                     |                                           */
/*   2    month1      31          |                                           |                                           */
/*   3    month2      35          |   drop idx;                               |                                           */
/*   4    month2      35          |                                           |                                           */
/*   5    month3      34          | run;quit;                                 |                                           */
/*   6    month4      31          |                                           |                                           */
/*   7    month4      39          | MACRO                                     |                                           */
/*   8    month4      30          | =====                                     |                                           */
/*   9    month5      33          |  %macro dynLvl(dsn,var);                  |                                           */
/*  10    month5      30          |                                           |                                           */
/*  11    month6      34          |   %dosubl('                               |                                           */
/*  12    month7      34          |    proc sql noprint;                      |                                           */
/*  13    month7      33          |      select                               |                                           */
/*  14    month7      37          |        count(distinct &var)               |                                           */
/*  15    month7      30          |      into                                 |                                           */
/*  16    month7      31          |        :_sessref_ trimmrd                 |                                           */
/*  17    month8      38          |      from                                 |                                           */
/*  18    month8      39          |        &dsn                               |                                           */
/*                                |    ;quit;                                 |                                           */
/*                                |   ')                                      |                                           */
/*                                |                                           |                                           */
/*                                |    &_sessref_                             |                                           */
/*                                |                                           |                                           */
/*                                |  %mend dynLvl;                            |                                           */
/*                                |                                           |                                           */
/**************************************************************************************************************************/

/*        _            _  __ _           _   _
/ |   ___| | __ _ _ __(_)/ _(_) ___ __ _| |_(_) ___  _ __
| |  / __| |/ _` | `__| | |_| |/ __/ _` | __| |/ _ \| `_ \
| | | (__| | (_| | |  | |  _| | (_| (_| | |_| | (_) | | | |
|_|  \___|_|\__,_|_|  |_|_| |_|\___\__,_|\__|_|\___/|_| |_|
*/

In my experience when you use DOSUBL inside a macro, any global macro
variable created in the dosubl side-session will be returned as a main session global
macro variable, unless you are careful to define it in the main session as %local.
So below, even though I commented out the %GLOBAL statement, the macro variable
FOO is still returned to the main session global
symbol table.

So I've always found it easy to return dosubl macro vars to the main session global
symbol table, and in situations like above I find it to be *too* easy.  I wish Rick
had decided to make the above create a %local macro variable.  But such is life.

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

%macro dynLvl(dsn,var);

 %***global foo;

 %let rc=
  %sysfunc(dosubl(%nrstr(
  proc sql noprint;
    select
      count(distinct &var)
    into
      :foo trimmed
    from
      &dsn
  ;quit;
 ))) ;

  &foo

 %mend dynLvl;

 %symdel foo /nowarn;
 %put
  %dynLvl(sashelp.class,name);
 %put _user_ ;

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/*   <<19>>                                                                                                               */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___        _                             _
|___ \    __| |_   _ _ __   __ _ _ __ ___ (_) ___    __ _ _ __ _ __ __ _ _   _
  __) |  / _` | | | | `_ \ / _` | `_ ` _ \| |/ __|  / _` | `__| `__/ _` | | | |
 / __/  | (_| | |_| | | | | (_| | | | | | | | (__  | (_| | |  | | | (_| | |_| |
|_____|  \__,_|\__, |_| |_|\__,_|_| |_| |_|_|\___|  \__,_|_|  |_|  \__,_|\__, |
               |___/                                                     |___/
*/
/*----                                                                   ----*/
/*----  my autoexec file has this code                                   ----*/
/*----  proc optsave data=sasuser.optsave;run;                           ----*/
/*----  so I can resore my environment if I mess it up                   ----*/
/*----                                                                   ----*/

/*
 _ __ ___   __ _  ___ _ __ ___
| `_ ` _ \ / _` |/ __| `__/ _ \
| | | | | | (_| | (__| | | (_) |
|_| |_| |_|\__,_|\___|_|  \___/

*/


%macro dynLvl(dsn,var);

 %dosubl('
  proc sql noprint;
    select
      count(distinct &var)
    into
      :_sessref_
    from
      &dsn
  ;quit;
 ')

  &_sessref_

%mend dynLvl;

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/
Data have;
input Month $ @@;
lunch=int(10*uniform(1232)+30);
cards;
month1 month1 month2
month2 month3 month4
month4 month4 month5
month5 month6 month7
month7 month7 month7
month7 month8 month8
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* HAVE total obs=18                                                                                                      */
/*                                                                                                                        */
/* Obs   MONTH     LUNCH                                                                                                  */
/*                                                                                                                        */
/*  1    month1      38                                                                                                   */
/*  2    month1      31                                                                                                   */
/*  3    month2      35                                                                                                   */
/*  4    month2      35                                                                                                   */
/*  5    month3      34                                                                                                   */
/*  6    month4      31                                                                                                   */
/*  7    month4      39                                                                                                   */
/*  8    month4      30                                                                                                   */
/*  9    month5      33                                                                                                   */
/* 10    month5      30                                                                                                   */
/* 11    month6      34                                                                                                   */
/* 12    month7      34                                                                                                   */
/* 13    month7      33                                                                                                   */
/* 14    month7      37                                                                                                   */
/* 15    month7      30                                                                                                   */
/* 16    month7      31                                                                                                   */
/* 17    month8      38                                                                                                   */
/* 18    month8      39                                                                                                   */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

%let _sessref_=;

data want(drop=month sum lunch);

  array mon
      mon1-mon%left(%dynLvl(have,month));

  set have end=dne;
  by month;

  retain idx sum
     mon1-mon%left(%dynLvl(have,month)) 0;

  sum = ifn(first.month,lunch,sum+lunch);

  if last.month then do;
    idx=idx+1;
     mon[idx] = sum;
  end;

  if dne then output;

  drop idx;

run;quit;

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/


/**************************************************************************************************************************/
/*                                                                                                                        */
/* Obs    MON1    MON2    MON3    MON4    MON5    MON6    MON7    MON8                                                    */
/*                                                                                                                        */
/*  1      69      70      34      100     63      34      165     77                                                     */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/



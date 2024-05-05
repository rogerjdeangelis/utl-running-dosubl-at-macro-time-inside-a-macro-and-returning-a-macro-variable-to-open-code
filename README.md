# utl-running-dosubl-at-macro-time-inside-a-macro-and-returning-a-macro-variable-to-open-code
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

       Create a dynamic array inside a datastep (sort of)


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
    /*          INPUT                 |             PROCESS                       |        OUTPUT                             */
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
    /*   9    month5      33          | proc optload                              |                                           */
    /*  10    month5      30          |  data=sasuser.optsave;run;quit;           |                                           */
    /*  11    month6      34          | %symdel _sessref_;                        |                                           */
    /*  12    month7      34          |                                           |                                           */
    /*  13    month7      33          | %macro dynLvl(dsn,var);                   |                                           */
    /*  14    month7      37          |                                           |                                           */
    /*  15    month7      30          |  %global _sessref_;                       |                                           */
    /*  16    month7      31          |                                           |                                           */
    /*  17    month8      38          |  %dosubl('                                |                                           */
    /*  18    month8      39          |   proc sql noprint;                       |                                           */
    /*                                |     select                                |                                           */
    /*                                |       count(distinct &var)                |                                           */
    /*                                |     into                                  |                                           */
    /*                                |       :_sessref_                          |                                           */
    /*                                |     from                                  |                                           */
    /*                                |       &dsn                                |                                           */
    /*                                |   ;quit;                                  |                                           */
    /*                                |  ')                                       |                                           */
    /*                                |                                           |                                           */
    /*                                |   &_sessref_                              |                                           */
    /*                                |                                           |                                           */
    /*                                | %mend dynLvl;                             |                                           */
    /*                                |                                           |                                           */
    /*                                |                                           |                                           */
    /*                                |                                           |                                           */
    /**************************************************************************************************************************/

    /*                   _
    (_)_ __  _ __  _   _| |_
    | | `_ \| `_ \| | | | __|
    | | | | | |_) | |_| | |_
    |_|_| |_| .__/ \__,_|\__|
            |_|
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

    /*----  may not be needed                                                ----*/

    proc optload
     data=sasuser.optsave;run;quit;
    %symdel _sessref_;

    %macro dynLvl(dsn,var);

     %global _sessref_;

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
Running dosubl at macro time inside at macro returning a macro variable to open code

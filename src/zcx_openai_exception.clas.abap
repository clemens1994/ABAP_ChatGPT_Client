CLASS zcx_openai_exception DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.
    INTERFACES if_t100_dyn_msg.

    METHODS constructor
      IMPORTING textid    LIKE if_t100_message=>t100key OPTIONAL
                !previous LIKE previous                 OPTIONAL.

    CLASS-METHODS raise
      RAISING zcx_openai_exception.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_OPENAI_EXCEPTION IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.


  METHOD raise.
    RAISE EXCEPTION TYPE zcx_openai_exception USING MESSAGE.
  ENDMETHOD.
ENDCLASS.

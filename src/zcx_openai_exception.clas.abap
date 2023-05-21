class ZCX_OPENAI_EXCEPTION definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional .
  class-methods RAISE
    raising
      ZCX_OPENAI_EXCEPTION .
protected section.
private section.
ENDCLASS.



CLASS ZCX_OPENAI_EXCEPTION IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD raise.

    RAISE EXCEPTION TYPE zcx_openai_exception USING MESSAGE.

  ENDMETHOD.
ENDCLASS.

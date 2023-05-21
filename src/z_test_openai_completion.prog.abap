*&---------------------------------------------------------------------*
*& Report Z_TEST_OPENAI_PROMPT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_test_openai_completion.

DATA l_default_model TYPE c LENGTH 255 VALUE zif_openai_models=>mc_gpt_3_5_turbo.

SELECTION-SCREEN BEGIN OF BLOCK prompt WITH FRAME.

PARAMETERS p_prompt TYPE string DEFAULT 'Tell me a joke'
                                LOWER CASE.

SELECTION-SCREEN END OF BLOCK prompt.

SELECTION-SCREEN BEGIN OF BLOCK para WITH FRAME.

PARAMETERS:
  p_key    TYPE string LOWER CASE
                       OBLIGATORY
                       VISIBLE LENGTH 40,

  p_model  TYPE string DEFAULT l_default_model
                       VISIBLE LENGTH 15
                       LOWER CASE,

  p_maxtok TYPE i DEFAULT 250
                  VISIBLE LENGTH 15.

SELECTION-SCREEN END OF BLOCK para.

START-OF-SELECTION.

  DATA(lo_openai) = NEW zcl_openai_completion(
    i_model      = p_model
    i_max_tokens = p_maxtok
    i_api_key    = p_key ).

  TRY.

      WRITE lo_openai->query( p_prompt ).

    CATCH zcx_openai_exception INTO DATA(lx_exc).
      WRITE lx_exc->get_text( ).
  ENDTRY.

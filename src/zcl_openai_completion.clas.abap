CLASS zcl_openai_completion DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS query
      IMPORTING i_prompt        TYPE string
      RETURNING VALUE(r_answer) TYPE string
      RAISING   zcx_openai_exception.

    METHODS constructor
      IMPORTING i_model      TYPE string DEFAULT zif_openai_models=>mc_gpt_3_5_turbo
                i_max_tokens TYPE i      DEFAULT 250
                i_api_key    TYPE string.

  PRIVATE SECTION.
    TYPES: BEGIN OF lst_msg_cont,
             role    TYPE string,
             content TYPE string.
    TYPES: END OF lst_msg_cont.
    TYPES: BEGIN OF lst_choices,
             message       TYPE lst_msg_cont,
             finish_reason TYPE string,
             index         TYPE i.
    TYPES: END OF lst_choices.
    TYPES: BEGIN OF lst_query_result,
             choices TYPE STANDARD TABLE OF lst_choices WITH DEFAULT KEY.
    TYPES: END OF lst_query_result.

    DATA m_api_key    TYPE string.
    DATA m_max_tokens TYPE i.
    DATA m_model      TYPE string.

    METHODS get_payload
      IMPORTING i_prompt         TYPE string
      RETURNING VALUE(r_payload) TYPE string.

    METHODS create_client
      RETURNING VALUE(ro_client) TYPE REF TO if_http_client
      RAISING   zcx_openai_exception.

    METHODS prepare_client_for_request
      IMPORTING i_prompt  TYPE string
                io_client TYPE REF TO if_http_client
      RAISING   zcx_openai_exception.

    METHODS send_and_recieve_request
      IMPORTING io_client TYPE REF TO if_http_client
      RAISING   zcx_openai_exception.

    METHODS get_answer_from_query_result
      IMPORTING io_client       TYPE REF TO if_http_client
      RETURNING VALUE(r_answer) TYPE string.
ENDCLASS.


CLASS zcl_openai_completion IMPLEMENTATION.
  METHOD constructor.

    m_model = i_model.
    m_max_tokens = i_max_tokens.
    m_api_key = i_api_key.

  ENDMETHOD.

  METHOD create_client.

    cl_http_client=>create_by_url( EXPORTING  url                = 'https://api.openai.com/v1/chat/completions'
                                   IMPORTING  client             = ro_client
                                   EXCEPTIONS argument_not_found = 1
                                              plugin_not_active  = 2
                                              internal_error     = 3 ).
    IF sy-subrc <> 0.
      zcx_openai_exception=>raise( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_answer_from_query_result.

    DATA ls_query_result TYPE zcl_openai_completion=>lst_query_result.
    DATA l_json_data     TYPE string.

    l_json_data = io_client->response->get_cdata( ).

    /ui2/cl_json=>deserialize( EXPORTING json         = l_json_data
                                         pretty_name  = /ui2/cl_json=>pretty_mode-user
                                         assoc_arrays = abap_true
                               CHANGING  data         = ls_query_result ).

    READ TABLE ls_query_result-choices INDEX 1 INTO DATA(ls_choices).
    IF sy-subrc = 0.
      r_answer = ls_choices-message-content.
    ENDIF.

  ENDMETHOD.

  METHOD get_payload.

    r_payload = |{ '{"model":"' }| &&
                |{ m_model }| &&
                |{ '","messages":[{"role":"user","content":"' }| &&
                |{ i_prompt }| &&
                |{ '"}],"temperature":1,"top_p":1,"n":1,"stream":false,"max_tokens":' }| &&
                |{ m_max_tokens }| &&
                |{ ',"presence_penalty":0,"frequency_penalty":0}' }|.

  ENDMETHOD.

  METHOD prepare_client_for_request.

    DATA l_payload   TYPE string.
    DATA l_payload_x TYPE xstring.

    io_client->request->set_version( if_http_request=>co_protocol_version_1_0 ).

    io_client->request->set_header_field( name  = if_http_header_fields=>content_type
                                          value = 'application/json' ).

    io_client->request->set_header_field( name  = if_http_header_fields=>accept
                                          value = 'application/json' ).

    io_client->request->set_header_field( name  = if_http_header_fields=>authorization
                                          value = 'Bearer' && ` ` && m_api_key ).

    l_payload = get_payload( i_prompt ).

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING  text   = l_payload
*                 mimetype = space
*                 encoding =
      IMPORTING  buffer = l_payload_x
      EXCEPTIONS failed = 1
                 OTHERS = 2.
    IF sy-subrc <> 0.
      zcx_openai_exception=>raise( ).
    ENDIF.

    io_client->request->set_data( l_payload_x ).

    io_client->request->set_method( if_http_request=>co_request_method_post ).

  ENDMETHOD.

  METHOD query.

    DATA lo_client TYPE REF TO if_http_client.

    lo_client = create_client( ).

    prepare_client_for_request( io_client = lo_client
                                i_prompt  = i_prompt ).

    send_and_recieve_request( lo_client ).

    r_answer = get_answer_from_query_result( lo_client ).

  ENDMETHOD.

  METHOD send_and_recieve_request.

    io_client->send( EXCEPTIONS http_communication_failure = 1
                                http_invalid_state         = 2
                                http_processing_failed     = 3
                                http_invalid_timeout       = 4 ).
    IF sy-subrc <> 0.
      zcx_openai_exception=>raise( ).
    ENDIF.

    io_client->receive( EXCEPTIONS http_communication_failure = 1
                                   http_invalid_state         = 2
                                   http_processing_failed     = 3 ).
    IF sy-subrc <> 0.
      zcx_openai_exception=>raise( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

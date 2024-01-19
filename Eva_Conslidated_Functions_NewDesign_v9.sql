-- Purpose: Backend Eva script for the new design (Aug 2018) 
-- These functions are the core NLP/Semantic Analysis/AI engine to drive how the app behaves
-- Developed by: Krishnan Gopalan

--******************--
--Function Name: get_account_ending_from_user_query
-- Purpose: Function to derive the account ending number from user query
-- version: 0.0 - baseline version (KG)

CREATE OR REPLACE FUNCTION get_account_ending_number_from_user_query(user_query_text IN text, app_user_id IN integer, OUT s_ending_number text)
AS $$

DECLARE
  r text;
  s_ending_number_keyword text;
  s_matching_ending_number text;
BEGIN
  FOR r in (select distinct mask from plaidmanager_account where user_id = app_user_id) LOOP
    IF s_ending_number_keyword is NULL THEN
      s_ending_number_keyword := r; 
    ELSE 
      s_ending_number_keyword := CONCAT (s_ending_number_keyword, '|', r);
    END IF;   
  END LOOP;
  --RAISE INFO 'ending_number_string: <%>', s_ending_number_keyword;
  select (regexp_matches(concat(' ', lower(user_query_text) , ' '), lower(s_ending_number_keyword), 'g'))[1] into s_matching_ending_number; 
  --RAISE INFO 'matching ending number : <%>', s_matching_ending_number;
  s_ending_number :=s_matching_ending_number; 
  --RAISE INFO ' ending number : <%>', s_ending_number;
EXCEPTION WHEN OTHERS THEN
  s_ending_number := NULL; 
  --RAISE INFO 'inside exception: <%>', s_ending_number_keyword;

END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_account_ending_number_from_user_query(user_query_text IN text, app_user_id IN integer, OUT s_ending_number text)
  OWNER TO evadev;

--******************--

--Function Name: get_account_name_from_user_query
-- Purpose: Function to derive the plaid account name from user query
-- version: 0.0 - baseline version
-- version 0.1 -  - added an additional OUT param called s_matched_account_name_keyword to use in results screen for building display message

CREATE OR REPLACE FUNCTION get_account_name_from_user_query(user_query_text IN text, OUT s_plaid_account_name text, OUT s_matched_account_name_keyword text)
AS $$

DECLARE
  r text;
  s_account_name_keywords text;

BEGIN
  select parameter_value from configure_globalparameter where parameter_name = 'account_name_keywords' and language = 'en' into s_account_name_keywords; 
  FOR r in (select (regexp_matches(concat(' ',lower(user_query_text) , ' '), lower(s_account_name_keywords), 'g'))[1]) LOOP
    ----RAISE INFO 'Matched string: <%>', r;
    SELECT  plaid_account_name, keyword 
    from configure_accountnamequeryconditionvaluepattern where lower(keyword) = lower(r) into s_plaid_account_name, s_matched_account_name_keyword;  
  END LOOP;
  --RAISE INFO 'plaid account name: <%>', s_plaid_account_name;
  --RAISE INFO 'matched account name keyword: <%>', s_matched_account_name_keyword;

EXCEPTION WHEN OTHERS THEN 
  s_plaid_account_name := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_account_name_from_user_query(user_query_text IN text, OUT s_plaid_account_name text, OUT s_matched_account_name_keyword text) OWNER TO evadev;

--******************--

--Function Name: get_account_subtype_from_user_query
-- Purpose: Function to derive the account_subtype from user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_account_subtype_from_user_query(user_query_text IN text, OUT s_plaid_account_subtype text)
AS $$

DECLARE
  r text;
  s_matched_account_subtype_keyword text;
  s_account_subtype_keywords text;

BEGIN
  select parameter_value from configure_globalparameter where parameter_name = 'account_subtype_keywords' and language = 'en' into s_account_subtype_keywords; 
  FOR r in (select (regexp_matches(concat(' ',lower(user_query_text) ,' '), lower(s_account_subtype_keywords), 'g'))[1]) LOOP
    ----RAISE INFO 'Matched string: <%>', r;
    SELECT  plaid_account_subtype
    from configure_accountsubtypequeryconditionvaluepattern where lower(keyword) = lower(r) into s_plaid_account_subtype;  
  END LOOP;
  --RAISE INFO 'plaid account sub type: <%>', s_plaid_account_subtype;
EXCEPTION WHEN OTHERS THEN 
  s_plaid_account_subtype := NULL; 
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_account_subtype_from_user_query(user_query_text IN text, OUT s_account_subtype text)
OWNER TO evadev;

--******************--


--Function Name: get_airline_name_from_user_query
-- Purpose: Function to derive the airline name from user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_airline_name_from_user_query(user_query_text IN text, OUT s_airline_name text, OUT s_matched_airline_keyword text)
AS $$

DECLARE
  r text;
  s_airline_keywords text;

BEGIN
  select parameter_value from configure_globalparameter where parameter_name = 'global_airline_keywords' and language = 'en' into s_airline_keywords; 
  FOR r in (select (regexp_matches(concat(' ', lower(user_query_text) , ' '), lower(s_airline_keywords), 'g'))[1]) LOOP
    SELECT  airline_name, keyword
    from configure_airlinequeryconditionvaluepattern where lower(keyword) = lower(rtrim(ltrim(r))) into s_airline_name, s_matched_airline_keyword;  
  END LOOP;
  --RAISE INFO 'airline name: <%>', s_airline_name;
  --RAISE INFO 'matched airline keyword : <%>', s_matched_airline_keyword;
EXCEPTION WHEN OTHERS THEN 
  s_airline_name :=NULL;
  s_matched_airline_keyword :=NULL; 
  --RAISE INFO 'inside exception: <%>', s_airline_name;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_airline_name_from_user_query(user_query_text IN text, OUT s_airline_name text, OUT s_matched_airline_keyword text) OWNER TO evadev;

--******************--

--Function Name: get_amount_from_user_query
-- Purpose: Function to derive the amount froma user query
-- version: 0.0 - baseline version
-- 

CREATE OR REPLACE FUNCTION get_amount_from_user_query(user_query_text IN text, OUT s_amount text)
AS $$
DECLARE
  r text;
  s_amount_keyword text;
BEGIN
  select parameter_value from configure_globalparameter where parameter_name = 'amount_keywords'  and language = 'en' into s_amount_keyword; 
  FOR r in (select (regexp_matches(concat(' ' , lower(user_query_text) , ' '), lower(s_amount_keyword), 'g'))[1]) LOOP
    RAISE INFO 'Matched string: <%>', r;
    SELECT  amount_value
    from configure_amountqueryconditionvaluepattern where keyword = r into s_amount;  
   END LOOP;     
   RAISE INFO 'Amount: <%>', s_amount;
EXCEPTION WHEN OTHERS THEN 
    s_amount := NULL;
END;
$$  LANGUAGE plpgsql;


ALTER FUNCTION get_amount_from_user_query(user_query_text IN text, OUT s_amount text)
  OWNER TO evadev;

--******************--

--Function Name: get_date_from_user_query
-- Purpose: Function to derive the from date and to date froma user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_date_from_user_query(user_query_text IN text, OUT s_from_date text,OUT s_to_date text, OUT s_matched_date_keyword text)
AS $$

DECLARE
  r text;
  s_date_keyword text;
  s_result_type text;
  s_from_date_temp text;
  s_to_date_temp text;
  s_from_date_formula text;
  s_to_date_formula text;
  s_calendar_keywords text;
  s_date1 text := NULL;
  s_date2 text := NULL;
  s_date3 text := NULL;
  s_date4 text := NULL;
  s_date_swap text;
BEGIN
  select parameter_value from configure_globalparameter where parameter_name = 'date_keywords' and language = 'en' into s_calendar_keywords; 
  FOR r in (select (regexp_matches(concat(' ', lower(user_query_text) , ' '), lower(s_calendar_keywords), 'g'))[1]) LOOP
    --RAISE INFO 'Matched string: <%>', r;
    s_matched_date_keyword :=r;

    SELECT  keyword, result_type, from_date_value, to_date_value, from_date_formula, to_date_formula 
    from configure_datequeryconditionvaluepattern where lower(keyword) = lower(r) and language_code = 'en' into s_date_keyword, s_result_type,s_from_date_temp, s_to_date_temp, s_from_date_formula, s_to_date_formula; 
    --RAISE INFO 's_date_keyword: <%>', s_date_keyword;
    --RAISE INFO 's_result_type: <%>', s_result_type;
    --RAISE INFO 's_from_date_temp: <%>', s_from_date_temp;
    --RAISE INFO 's_from_date_formula: <%>', s_from_date_formula;
    --RAISE INFO 's_to_date_formula: <%>', s_to_date_formula;

    IF (s_result_type = 'formula') THEN
    --RAISE INFO 'From Date formula: <%>', s_from_date_formula;
    --RAISE INFO 'To Date formula: <%>', s_to_date_formula;
    EXECUTE s_from_date_formula into s_from_date_temp;
    EXECUTE s_to_date_formula into s_to_date_temp; 
    --RAISE INFO 'From Date temp: <%>', s_from_date_temp;
    --RAISE INFO 'To Date temp: <%>', s_to_date_temp;
    END IF;   
   IF (s_date1 IS NULL) and (s_date2 IS NULL) THEN
      s_date1 :=s_from_date_temp; 
      s_date2 :=s_to_date_temp; 
    ELSE 
      s_date3 :=s_from_date_temp;   
      s_date4 :=s_to_date_temp;        
    END IF;      
   END LOOP;
   ----RAISE INFO 's1 date: <%>', s_date1;
   ----RAISE INFO 's2 Date : <%>', s_date2; 
   ----RAISE INFO 's3 Date : <%>', s_date3;
   ----RAISE INFO 's4 Date : <%>', s_date4;  
   
   IF (s_date3 IS NULL) and (s_date4 IS NULL) THEN 
    s_from_date :=s_date1;
    s_to_date := s_date2; 
   ELSIF ((s_date1 = s_date2) AND (s_date3 IS NOT NULL) and (s_date4 IS NOT NULL) and (s_date3 = s_date4)) THEN
    s_from_date :=s_date1;
    s_to_date :=s_date3; 
   ELSE 
    s_from_date :=s_date1;
    s_to_date :=s_date4; 
   END IF; 
   IF to_date(s_from_date, 'YYYY-MM-DD') > to_date(s_to_date, 'YYYY-MM-DD') THEN 
    s_date_swap:=s_to_date;
    s_to_date:=s_from_date;
    s_from_date:=s_date_swap;
   END IF;         
    RAISE INFO 'From Date : <%>', s_from_date;
    RAISE INFO 'To Date : <%>', s_to_date; 
    RAISE INFO 'Matched date keyword : <%>', s_matched_date_keyword; 
EXCEPTION WHEN OTHERS THEN 
  --RAISE INFO 'inside get_date exception: <%>', s_from_date;
  s_from_date := NULL;
  s_to_date := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_date_from_user_query(user_query_text IN text, OUT s_from_date text,OUT s_to_date text, OUT s_matched_date_keyword text)
  OWNER TO evadev;

--******************--

--Function Name: get_biz_name_from_user_query
-- Purpose: Function to derive the biz name from user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_biz_name_from_user_query(user_query_text IN text, OUT s_biz_name text, OUT s_matched_biz_name_keyword text)
AS $$

DECLARE
  r text;
  updated_user_query_text text;
  s_biz_names_keywords text;


BEGIN
  updated_user_query_text:= replace(user_query_text,'''', '');
  updated_user_query_text:= replace(updated_user_query_text,'(', '');
  updated_user_query_text:= replace(updated_user_query_text,')', '');
  updated_user_query_text:= replace(updated_user_query_text,'*', '');
  updated_user_query_text:= replace(updated_user_query_text,'#', '');
  updated_user_query_text:= replace(updated_user_query_text,'*', '');
  updated_user_query_text:= replace(updated_user_query_text,',', '');
  updated_user_query_text:= replace(updated_user_query_text,'/', '');
  RAISE INFO 'updated_user_query_text: <%>', updated_user_query_text;

  select parameter_value from configure_globalparameter where parameter_name = 'global_biz_name_keywords' and language = 'en' into s_biz_names_keywords; 
  select (regexp_matches(concat(' ', lower(updated_user_query_text) , ' '), lower(s_biz_names_keywords), 'g'))[1] into s_biz_name; 
  --RAISE INFO 's_biz_name : <%>', s_biz_name;
  --RAISE INFO 'matched s_matched_biz_name_keyword keyword : <%>', s_matched_biz_name_keyword;
EXCEPTION WHEN OTHERS THEN 
  s_biz_name :=NULL;
  s_matched_biz_name_keyword :=NULL; 
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_biz_name_from_user_query(user_query_text IN text, OUT s_biz_name text, OUT s_matched_biz_name_keyword text) OWNER TO evadev;

--******************--

--Function Name: get_charge_category_from_user_query
-- Purpose: Function to derive the charge (spend category) from user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_charge_category_from_user_query(user_query_text IN text, OUT s_category_levels_to_check text, OUT s_category_level0 text, OUT s_category_level1 text, OUT s_category_level2 text, OUT s_matched_category_keyword text)
AS $$

DECLARE
  r text;
--  s_matched_category_keyword character varying(400);
  s_result_type text;
  s_charge_category_keywords text;

BEGIN
  select parameter_value from configure_globalparameter where parameter_name = 'charge_category_keywords'  and language = 'en' into s_charge_category_keywords; 
  FOR r in (select (regexp_matches(concat(' ', lower(user_query_text) , ' '), lower(s_charge_category_keywords), 'g'))[1]) LOOP
    ----RAISE INFO 'Matched string: <%>', r;
    s_matched_category_keyword :=r;
    SELECT  levels_to_check, category_level0, category_level1, category_level2
    from configure_categoryqueryconditionvaluepattern where lower(rtrim(ltrim(keyword))) = lower(rtrim(ltrim(r))) into s_category_levels_to_check, s_category_level0, s_category_level1, s_category_level2;  
    EXIT; 
  END LOOP;
   --RAISE INFO 'category0: <%>', s_category_level0;
   --RAISE INFO 'category1 : <%>', s_category_level1; 
   --RAISE INFO 'category2 : <%>', s_category_level2;
   --RAISE INFO 'nlevels : <%>', s_category_levels_to_check;
   --RAISE INFO 'matched keyword : <%>', s_matched_category_keyword;
EXCEPTION WHEN OTHERS THEN  
  s_category_levels_to_check := NULL;
  s_category_level0 := NULL; 
  s_category_level1 := NULL; 
  s_category_level2 := NULL; 
  s_matched_category_keyword := NULL; 

END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_charge_category_from_user_query(user_query_text IN text, OUT s_category_levels_to_check text, OUT s_category_level0 text, OUT s_category_level1 text, OUT s_category_level2 text, OUT s_matched_category_keyword text) OWNER TO evadev;

--******************--

--Function Name: get_hotel_name_from_user_query
-- Purpose: Function to derive the hotel name from user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_hotel_name_from_user_query(user_query_text IN text, OUT s_hotel_name text, OUT s_matched_hotel_keyword text)
AS $$

DECLARE
  r text;
  s_hotel_keywords text;

BEGIN
  select parameter_value from configure_globalparameter where parameter_name = 'global_hotel_keywords' and language = 'en' into s_hotel_keywords; 
  FOR r in (select (regexp_matches(concat(' ', lower(user_query_text) , ' '), lower(s_hotel_keywords), 'g'))[1]) LOOP
    SELECT  hotel_name, keyword
    from configure_hotelqueryconditionvaluepattern where lower(rtrim(ltrim(keyword))) = lower(rtrim(ltrim(r))) into s_hotel_name, s_matched_hotel_keyword;  
  END LOOP;
  --RAISE INFO 'hotel name: <%>', s_hotel_name;
  --RAISE INFO 'matched hotel keyword : <%>', s_matched_hotel_keyword;
EXCEPTION WHEN OTHERS THEN 
  s_hotel_name :=NULL;
  s_matched_hotel_keyword :=NULL; 
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_hotel_name_from_user_query(user_query_text IN text, OUT s_hotel_name text, OUT s_matched_hotel_keyword text) OWNER TO evadev;

--******************--

--Function Name: get_institution_id_from_user_query
-- Purpose: Function to derive the plaid institution id from user query based on bank keyword utterances
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_institution_id_from_user_query(user_query_text IN text, OUT s_plaid_institution_id text, OUT s_matched_institution text)
AS $$

DECLARE
  r text;
  s_matched_institution_keyword text;
  s_institution_keywords text;

BEGIN
  --RAISE INFO 'Inside main body <%>', user_query_text;
  select parameter_value from configure_globalparameter where parameter_name = 'institution_keywords' and language = 'en'  into s_institution_keywords; 
  --RAISE INFO 'after select  <%>', s_institution_keywords;
  FOR r in select (regexp_matches(concat(' ', lower(user_query_text) , ' '), lower(s_institution_keywords), 'g'))[1] LOOP
    SELECT  plaid_institution_id, institution_name
    from configure_institutionqueryconditionvaluepattern where lower(rtrim(ltrim(keyword))) = lower(rtrim(ltrim(r))) into s_plaid_institution_id, s_matched_institution;  
    --RAISE INFO 'Matched string: <%>', s_plaid_institution_id;
    --RAISE INFO 'Matched s_matched_institution: <%>', s_matched_institution;

    EXIT; 
  END LOOP;
  --RAISE INFO 'plaid institution type: <%>', s_plaid_institution_id;
  --RAISE INFO 'matched institution : <%>', s_matched_institution;
EXCEPTION WHEN OTHERS THEN 
  --RAISE INFO 'inside exception  : <%>', s_matched_institution;
  s_plaid_institution_id :=NULL;
  s_matched_institution :=NULL; 
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_institution_id_from_user_query(user_query_text IN text, OUT s_plaid_institution_id text, OUT s_matched_institution text) OWNER TO evadev;

--******************--

-- Function Name: get_reward_category_info_from_user_query
-- Purpose: Function to derive the reward category information user query (information such as what reward category to choose, airline, hotel name, biz name etc.)
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_reward_category_info_from_user_query(p_user_query_text IN text, OUT s_reward_category_name text,OUT s_airline_name text, OUT s_matched_airline_keyword text, OUT s_hotel_name text, OUT s_matched_hotel_keyword text,  OUT s_biz_name text, OUT s_matched_biz_name_keyword text)
AS $$

DECLARE
  r record;
BEGIN
   FOR r IN SELECT *  FROM configure_categoryreward order by id asc LOOP
            IF ((regexp_matches(concat(' ', lower(p_user_query_text), ' '), lower(r.keywords), 'g'))[1]) IS NOT NULL THEN
                
                s_reward_category_name := r.name; 

                IF r.is_airline_check THEN    
                   SELECT * from get_airline_name_from_user_query(p_user_query_text) INTO s_airline_name, s_matched_airline_keyword;       
                END IF;  
                IF r.is_hotel_name_check THEN        
                    SELECT * from get_hotel_name_from_user_query(p_user_query_text) INTO s_hotel_name, s_matched_hotel_keyword;          
                END IF;  
                IF r.is_biz_name_check THEN
                    select * from get_biz_name_from_user_query(p_user_query_text) into s_biz_name,s_matched_biz_name_keyword ;
                END IF;
                --RAISE INFO 'reward Category Name: <%>', s_reward_category_name;
                --RAISE INFO 'Airline name: <%>', s_airline_name;
                --RAISE INFO 'Hotelname: <%>', s_hotel_name;
                --RAISE INFO 'Biz name: <%>', s_biz_name;
                EXIT;  -- to make sure only the first intent gets executed..

            ELSE 
                s_reward_category_name := 'all_category_reward';
                s_airline_name := NULL;
                s_matched_airline_keyword := NULL;
                s_hotel_name := NULL;
                s_matched_hotel_keyword := NULL;
                s_biz_name := NULL;
                s_matched_biz_name_keyword := NULL;
            END IF;

    END LOOP;

    EXCEPTION WHEN OTHERS THEN 
        --RAISE INFO 'inside exception: <%>', s_reward_category_name;

        s_reward_category_name := 'all_category_reward';
        s_airline_name := NULL;
        s_matched_airline_keyword := NULL;
        s_hotel_name := NULL;
        s_matched_hotel_keyword := NULL;
        s_biz_name := NULL;
        s_matched_biz_name_keyword := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_reward_category_info_from_user_query(p_user_query_text IN text, OUT s_reward_category_name text,OUT s_airline_name text, OUT s_matched_airline_keyword text, OUT s_hotel_name text, OUT s_matched_hotel_keyword text,  OUT s_biz_name text, OUT s_matched_biz_name_keyword text)
  OWNER TO evadev;

--******************--

--Function Name: get_txn_biz_name_from_user_query
--Purpose: to get the transaction biz name from the user query 
-- version: 0.0 - baseline version
-- 

CREATE OR REPLACE FUNCTION get_txn_biz_name_from_user_query(user_query_text IN text, app_user_id IN integer, OUT s_txn_biz_name text)
AS $$

DECLARE
  r text;
  s_biz_name_keyword text;
  s_matching_biz_name text;
BEGIN
  FOR r in (select distinct name from plaidmanager_transaction where user_id = app_user_id) LOOP
    r:= replace(r,'''', '');
    r:= replace(r,'(', '');
    r:= replace(r,')', '');
    r:= replace(r,'*', '');
    r:= replace(r,'#', '');
    r:= replace(r,'*', '');
    r:= replace(r,',', '');
    r:= replace(r,'/', '');
    IF s_biz_name_keyword is NULL THEN
      s_biz_name_keyword := r; 
    ELSE 
      s_biz_name_keyword := CONCAT (s_biz_name_keyword, '|', r);
    END IF;   
  END LOOP;
  --RAISE INFO 'biz_name_keyword: <%>', s_biz_name_keyword;
  select (regexp_matches(concat(' ', lower(user_query_text), ' '), lower(s_biz_name_keyword), 'g'))[1] into s_matching_biz_name; 
  --RAISE INFO 'matching bizname : <%>', s_matching_biz_name;
  s_txn_biz_name := s_matching_biz_name;
  --RAISE INFO 'txn bizname : <%>', s_txn_biz_name;
EXCEPTION WHEN OTHERS THEN 
  --RAISE INFO 'inside biz name exception: <%>', s_matching_biz_name;
  s_txn_biz_name := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_txn_biz_name_from_user_query(user_query_text IN text, app_user_id IN integer, OUT s_txn_biz_name text)
  OWNER TO evadev;

--******************--

--Function Name: build_json_output
-- Purpose: Function to build the json output based on the different inputs
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION build_json_output(query_id IN text, user_query_text IN text, display_screen_name IN text, display_type IN text, display_message IN text, voice_message IN text, display_value IN text, display_notes IN text, transaction_output_as_json IN text, graph_data_as_json IN text, account_data_as_json IN text, card_reco_data_as_json IN text, OUT json_output text)
AS $$
DECLARE 
s_record text; 
BEGIN
    IF transaction_output_as_json IS NULL THEN 
      transaction_output_as_json :='[]'; 
    END IF; 
    IF graph_data_as_json IS NULL THEN 
      graph_data_as_json :='[]'; 
    END IF; 
    IF account_data_as_json IS NULL THEN 
        account_data_as_json :='[]'; 
    END IF; 
    IF card_reco_data_as_json IS NULL THEN 
        card_reco_data_as_json :='[]'; 
    END IF; 

    json_output := concat ('{"header": {"query_id": "',query_id, '","user_query_text": "',user_query_text,'","display_screen_name": "', display_screen_name,'","display_type": "', display_type,'","display_message": "', display_message, '","voice_message": "', voice_message, '","display_value": "', display_value,  '","display_notes": "', display_notes, '"}, "transactions": ', transaction_output_as_json, ',  "graph_data":', graph_data_as_json, ', "account_data":', account_data_as_json, ', "card_reco_data":', card_reco_data_as_json, '}');
    --RAISE INFO 'Result inside build_json_output: <%>', json_output; 
EXCEPTION WHEN OTHERS THEN
    display_screen_name :='results_screen'; 
    display_message :='Sorry :worried:, something went wrong, please try again.'; 
    voice_message := 'Sorry, something went wrong, please try again.'; 
    display_type := 'display_message';
    json_output := concat ('{"header": {"query_id": "',query_id, '","user_query_text": "',user_query_text,'","display_screen_name": "', display_screen_name,'","display_type": "', display_type,'","display_message": "', display_message, '","voice_message": "', voice_message, '","display_value": "', display_value,  '","display_notes": "', display_notes, '"}, "transactions": ', transaction_output_as_json, ',  "graph_data":', graph_data_as_json, ', "account_data":', account_data_as_json, ', "card_reco_data":', card_reco_data_as_json, '}');

END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION build_json_output(query_id IN text, user_query_text IN text, display_screen_name IN text, display_type IN text, display_message IN text, voice_message IN text, display_value IN text, display_notes IN text, transaction_output_as_json IN text, graph_data_as_json IN text, account_data_as_json IN text, card_reco_data_as_json IN text, OUT json_output text) OWNER TO evadev;

--******************--


-- Function Name: build_insights_json_output
-- Purpose: Function to build the json output exclusively for insights
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION build_insights_json_output(query_id IN integer, s_snapshot_data_as_json IN text, s_transactions_data_as_json IN text, s_subscriptions_data_as_json IN text, s_spend_by_category_data_as_json IN text, s_utilization_data_as_json IN text, s_interest_paid_data_as_json IN text, s_improve_credit_data_as_json IN text, s_card_recommendation_data_as_json IN text, s_forecast_data_as_json IN text, OUT json_output_insights text)
AS $$
DECLARE 
s_record text; 
BEGIN
    --RAISE INFO 'inside xxx build_insights_json_output: <%>', query_id; 
    --RAISE INFO 'inside xxx build_insights_json_output and snapshot_output_as_json: <%>', s_snapshot_data_as_json; 

    IF s_snapshot_data_as_json IS NULL THEN 
      s_snapshot_data_as_json :='[]'; 
    END IF; 
    IF s_transactions_data_as_json IS NULL THEN 
        s_transactions_data_as_json :='[]'; 
    END IF; 
    IF s_subscriptions_data_as_json IS NULL THEN 
        s_subscriptions_data_as_json :='[]'; 
    END IF;
    IF s_spend_by_category_data_as_json IS NULL THEN 
        s_spend_by_category_data_as_json :='[]'; 
    END IF;
    IF s_utilization_data_as_json IS NULL THEN 
      s_utilization_data_as_json :='[]'; 
    END IF; 
    IF s_interest_paid_data_as_json IS NULL THEN 
      s_interest_paid_data_as_json :='[]'; 
    END IF; 
    IF s_improve_credit_data_as_json IS NULL THEN 
      s_improve_credit_data_as_json :='[]'; 
    END IF; 
    IF s_card_recommendation_data_as_json IS NULL THEN 
        s_card_recommendation_data_as_json :='[]'; 
    END IF; 

    IF s_forecast_data_as_json IS NULL THEN 
      s_forecast_data_as_json :='[]'; 
    END IF; 
    
    /* 
    IF s_fun_fact_data_as_json IS NULL THEN 
        s_fun_fact_data_as_json :='[]'; 
    END IF; 
    */

    --json_output_insights := concat('{"header": {"query_id": "',query_id, '","user_query_text": "',user_query_text,'","display_screen_name": "', display_screen_name,'","display_type": "', display_type,'","display_message": "', display_message, '","voice_message": "', voice_message, '","display_value": "', display_value,  '","display_notes": "', display_notes, '"}, "snapshot": ', snapshot_output_as_json, ',  "forecast":', forecast_data_as_json, ', "transactions":', transactions_data_as_json, ', "spend_by_category":', spend_by_category_data_as_json, ', "utilization":', utilization_data_as_json, ', "improve_credit":', improve_credit_data_as_json,', "card_recommendation":', card_recommendation_data_as_json,', "subscriptions":', subscriptions_data_as_json,', "interest_paid":', interest_paid_data_as_json,'}');
    json_output_insights := concat('{"header": {"query_id": "',query_id, '"},', s_snapshot_data_as_json, ',',s_transactions_data_as_json, ',',  s_subscriptions_data_as_json, ',' , s_spend_by_category_data_as_json, ',' , s_utilization_data_as_json , ',', s_interest_paid_data_as_json , ',', s_improve_credit_data_as_json, ',', s_card_recommendation_data_as_json, ',', s_forecast_data_as_json ,'}');


    --RAISE INFO 'Result inside the insights json function: <%>', json_output_insights; 
  EXCEPTION WHEN OTHERS THEN
    json_output_insights := concat('{"header": {"query_id": "',query_id, '"},', s_snapshot_data_as_json, ',',s_transactions_data_as_json, ',',  s_subscriptions_data_as_json, ',' , s_spend_by_category_data_as_json, ',' , s_utilization_data_as_json , ',', s_interest_paid_data_as_json , ',', s_improve_credit_data_as_json, ',', s_card_recommendation_data_as_json, ',', s_forecast_data_as_json ,'}');


END;
$$  LANGUAGE plpgsql;


ALTER FUNCTION build_insights_json_output(query_id IN integer, s_snapshot_data_as_json IN text, s_transactions_data_as_json IN text, s_subscriptions_data_as_json IN text, s_spend_by_category_data_as_json IN text, s_utilization_data_as_json IN text, s_interest_paid_data_as_json IN text, s_improve_credit_data_as_json IN text, s_card_recommendation_data_as_json IN text, s_forecast_data_as_json IN text, OUT json_output_insights text) OWNER TO evadev;

--******************--

--Function Name: insert_into_user_query_tear_down
-- Purpose: Function to insert new records into user_query_tear_down table 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION insert_into_user_query_tear_down(p_user_id IN integer, p_user_query_text IN text, p_query_source IN text, p_query_mode IN text, p_intent_name IN text, p_query_status IN text, p_display_type IN text, p_display_message IN text, p_display_value IN text, p_display_notes IN text, p_transaction_output_as_json IN text, p_graph_data_as_json IN text, p_results_json IN text, OUT s_user_query_id text)
AS $$

DECLARE
  n_user_count smallint; 
  s_display_screen_name text;

BEGIN
  IF (p_user_id IS NOT NULL) THEN 
    BEGIN
      RAISE INFO 'before insert onto  user_query_tear_down <%>', p_user_id;
      IF p_user_query_text IS NULL THEN 
        p_user_query_text := '';
      END IF; 
      IF s_display_screen_name IS NULL THEN 
        s_display_screen_name := '';
      END IF;
      IF p_user_id IS NULL THEN 
        p_user_id := 1;
      END IF;   
      IF p_query_source IS NULL THEN 
        p_query_source := '';
      END IF;
      IF p_query_mode IS NULL THEN 
        p_query_mode := '';
      END IF;
      IF p_intent_name IS NULL THEN 
        p_intent_name := '';
      END IF;
      IF p_query_status IS NULL THEN 
        p_query_status := '';
      END IF;
      IF p_display_type IS NULL THEN 
        p_display_type := '';
      END IF;
      IF p_display_message IS NULL THEN 
        p_display_message := '';
      END IF;
      IF p_display_value IS NULL THEN 
        p_display_value := '';
      END IF;
      IF p_display_notes IS NULL THEN 
        p_display_notes := '';
      END IF;
      IF p_transaction_output_as_json IS NULL THEN 
        p_transaction_output_as_json := '';
      END IF;
      IF p_graph_data_as_json IS NULL THEN 
        p_graph_data_as_json := '';
      END IF;
      IF p_results_json IS NULL THEN 
        p_results_json := '';
      END IF;
      INSERT INTO users_userqueryhistory (user_id, query_text, source, mode, intent_name, status, display_type, display_message, display_value, display_notes, transaction_output_as_json, graph_data_as_json, results_json, created_at, updated_at, display_screen_name) values (p_user_id, p_user_query_text, p_query_source, p_query_mode, p_intent_name,  p_query_status, p_display_type, p_display_message,p_display_value, p_display_notes,  p_transaction_output_as_json, p_graph_data_as_json, p_results_json, now(), now(), s_display_screen_name ) RETURNING id into s_user_query_id; 
      RAISE INFO 'returning user query id  <%>', s_user_query_id;      
    EXCEPTION WHEN OTHERS THEN
      RAISE INFO 'Inside insert exception  <%>', s_user_query_id; 
    END; 
  
  ELSE 
    s_user_query_id := null;
  END IF; 
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION insert_into_user_query_tear_down(p_user_id IN integer, p_user_query_text IN text, p_query_source IN text, p_query_mode IN text, p_intent_name IN text, p_query_status IN text, p_display_type IN text, p_display_message IN text, p_display_value IN text, p_display_notes IN text, p_transaction_output_as_json IN text, p_graph_data_as_json IN text, p_results_json IN text, OUT s_user_query_id text) OWNER TO evadev;

--******************--

--Function Name: get_available_balance
-- Purpose: Function to build the account available balance query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_available_balance(user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string_for_total_available text := null;
  s_sqlquery_string_for_account_json text :=null;
  s_sqlwhere text := null;
  s_orderby text := null;

BEGIN

  IF user_id IS NOT NULL THEN 

    s_sqlquery_string_for_total_available := ' select cast(sum(a.available_balance) as money) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i '; 

    s_sqlquery_string_for_account_json := ' SELECT i.name as "institution_name", coalesce(i.color_scheme,''4A4A4A'') as "color_scheme", i.code as "institution_id", a.name as "name", a.official_name as "official_name",a.mask as "ending_number", initcap(a.account_sub_type) as "subtype" , (cast(a.available_balance as money)) as "available_balance", (cast(a.current_balance as money)) as "current_balance", (cast(a.balance_limit as money)) as "credit_limit", round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1) as "utilization_as_value", (case when (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) <= 9 THEN ''Excellent'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 9 and 29 THEN ''Very Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 29 and 49 THEN ''Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 49 and 75 THEN ''Fair'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 75 and 100 THEN ''Very High'' ELSE ''Not Applicable'' END) as "utilizaton_band", concat(round(((a.current_balance/case a.balance_limit WHEN null THEN NULLIF(a.available_balance,0) WHEN 0 THEN NULLIF(a.available_balance,0) ELSE a.balance_limit END) *100),1) ,''%'') as "utilization_percent_as_text", a.account_id FROM plaidmanager_account a, plaidmanager_item item, plaidmanager_institutionmaster i '; 
    
    s_sqlwhere := concat(' where 1 = 1 and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and a.user_id =   ', user_id );   
    s_orderby := ' order by a.name '; 

    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
  
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 

    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 

    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

    s_sqlquery_string_for_total_available := concat(s_sqlquery_string_for_total_available, s_sqlwhere); 
    s_sqlquery_string_for_account_json := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_account_json, s_sqlwhere, s_orderby , ') row' ); 

    RAISE INFO 's_sqlstring total available: <%>', s_sqlquery_string_for_total_available;
    RAISE INFO 's_sqlstring for account json <%>', s_sqlquery_string_for_account_json;

    EXECUTE s_sqlquery_string_for_total_available into display_value;
    EXECUTE s_sqlquery_string_for_account_json into account_data_as_json;

  ELSE 
    RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    account_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  account_data_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_available_balance(user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text) OWNER TO evadev;


--******************--

--Function Name: get_credit_card_listing
-- Purpose: Function to get a listing of all credit cards
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_credit_card_listing(user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string_for_total_available text := null;
  s_sqlquery_string_for_account_json text :=null;
  s_sqlwhere text := null;
  s_orderby text := null;

BEGIN

  IF user_id IS NOT NULL THEN 

    s_sqlquery_string_for_total_available := ' select cast(sum(a.available_balance) as money) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i  '; 

    s_sqlquery_string_for_account_json := ' SELECT i.name as "institution_name", coalesce(i.color_scheme,''4A4A4A'') as "color_scheme", i.code as "institution_id", a.name as "name", a.official_name as "official_name",a.mask as "ending_number", initcap(a.account_sub_type) as "subtype" , (cast(a.available_balance as money)) as "available_balance", (cast(a.current_balance as money)) as "current_balance", (cast(a.balance_limit as money)) as "credit_limit", round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1) as "utilization_as_value", (case when (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) <= 9 THEN ''Excellent'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 9 and 29 THEN ''Very Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 29 and 49 THEN ''Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 49 and 75 THEN ''Fair'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 75 and 100 THEN ''Very High'' ELSE ''Not Applicable'' END) as "utilizaton_band", concat(round(((a.current_balance/case a.balance_limit WHEN null THEN NULLIF(a.available_balance,0) WHEN 0 THEN NULLIF(a.available_balance,0) ELSE a.balance_limit END) *100),1) ,''%'') as "utilization_percent_as_text", a.account_id FROM plaidmanager_account a, plaidmanager_item item, plaidmanager_institutionmaster i '; 

    
    s_sqlwhere := concat(' where 1 = 1 and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and a.account_sub_type = ''credit card'' and a.user_id =   ', user_id );   
    s_orderby := ' order by a.name '; 

    s_sqlquery_string_for_total_available := concat(s_sqlquery_string_for_total_available, s_sqlwhere); 
    s_sqlquery_string_for_account_json := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_account_json, s_sqlwhere, s_orderby , ') row' ); 

    RAISE INFO 's_sqlstring total available: <%>', s_sqlquery_string_for_total_available;
    RAISE INFO 's_sqlstring for account json <%>', s_sqlquery_string_for_account_json;

    EXECUTE s_sqlquery_string_for_total_available into display_value;
    EXECUTE s_sqlquery_string_for_account_json into account_data_as_json;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    account_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  account_data_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_credit_card_listing(user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_utilization
-- Purpose: Function to build the utilization query and value based on user ipnuts
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_utilization(user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_utilization text := null;
  s_sqlquery_string_for_account_json text :=null;
  s_sqlwhere text := null;
  s_orderby text := null;

BEGIN

  IF user_id IS NOT NULL THEN 
    s_sqlquery_utilization := ' select concat(round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%'') from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i  '; 
    s_sqlquery_string_for_account_json := ' SELECT i.name as "institution_name", coalesce(i.color_scheme,''4A4A4A'') as "color_scheme", i.code as "institution_id", a.name as "name", a.official_name as "official_name",a.mask as "ending_number", initcap(a.account_sub_type) as "subtype" , (cast(a.available_balance as money)) as "available_balance", (cast(a.current_balance as money)) as "current_balance", (cast(a.balance_limit as money)) as "credit_limit", round(((a.current_balance/case a.balance_limit WHEN null THEN a.available_balance WHEN 0 THEN a.available_balance ELSE a.balance_limit END) *100),1) as "utilization_as_value", (case when (round(((a.current_balance/case a.balance_limit WHEN null THEN a.available_balance WHEN 0 THEN a.available_balance ELSE a.balance_limit END) *100),1)) <= 9 THEN ''Excellent'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN a.available_balance WHEN 0 THEN a.available_balance ELSE a.balance_limit END) *100),1)) between 9 and 29 THEN ''Very Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN a.available_balance WHEN 0 THEN a.available_balance ELSE a.balance_limit END) *100),1)) between 29 and 49 THEN ''Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN a.available_balance WHEN 0 THEN a.available_balance ELSE a.balance_limit END) *100),1)) between 49 and 75 THEN ''Fair'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN a.available_balance WHEN 0 THEN a.available_balance ELSE a.balance_limit END) *100),1)) between 75 and 100 THEN ''Very High'' ELSE ''Not Applicable'' END) as "utilizaton_band", concat(round(((a.current_balance/case a.balance_limit WHEN null THEN a.available_balance WHEN 0 THEN a.available_balance ELSE a.balance_limit END) *100),1) ,''%'') as "utilization_percent_as_text", a.account_id FROM plaidmanager_account a, plaidmanager_item item, plaidmanager_institutionmaster i '; 
    
    s_sqlwhere := concat(' where 1 = 1 and lower(a.account_sub_type) in ( ''credit card'') and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and a.user_id =   ', user_id );   
    s_orderby := ' order by a.name '; 


    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
  
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.ending_number = ''', s_ending_number, ''' ' ); 
    END IF; 

/*    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.subtype) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 
*/
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.institution_id) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

    s_sqlquery_utilization := concat(s_sqlquery_utilization, s_sqlwhere); 
    s_sqlquery_string_for_account_json := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_account_json, s_sqlwhere, s_orderby , ') row' ); 

    RAISE INFO 's_sqlstring utilization: <%>', s_sqlquery_utilization;
    RAISE INFO 's_sqlstring for account json <%>', s_sqlquery_string_for_account_json;
    
    EXECUTE s_sqlquery_utilization into display_value;
    EXECUTE s_sqlquery_string_for_account_json into account_data_as_json;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    account_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  account_data_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_utilization(user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_improve_credit_score
-- Purpose: Function to provide tips to improve credit score overall (and provide recommendations by each account as well)
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_improve_credit_score(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_message text, OUT display_notes text, OUT voice_message text, OUT account_data_as_json text)
AS $$

DECLARE
  s_sqlquery_utilization text := null;
  s_sqlquery_string_for_account_json text :=null;
  s_sqlwhere text := null;
  s_orderby text := null;
  n_utilization_value numeric; 
  s_utilization_band text; 
  s_utilization_message text; 
  s_sqlquery_current_balance text; 
  n_current_balance numeric; 
  n_jump_to_next_level numeric; 
  n_excellent_to_peak integer :=2; 
  n_very_good_to_excellent integer := 9; 
  n_good_to_very_good integer := 29; 
  n_fair_to_good integer := 49; 
  n_bad_to_fair integer :=75; 
  n_payoff_to_improve numeric; 
  n_account_payoff_to_improve numeric; 
  n_account_jump_to_next_level numeric; 
  r record; 
  n_account_current_balance numeric; 
  n_account_utilization numeric; 
  s_account_message_filler text := '<br><br> :point_right: '; 
  s_account_message_filler_first_message text := ':point_right: '; 
  s_user_nickname text;
  s_institution_name text;
  s_institution_id text;
  s_color_scheme text;
  n_total_account_payoff_to_improve numeric; 

BEGIN

  n_payoff_to_improve :=0; 
  n_total_account_payoff_to_improve :=0; 
  s_sqlquery_utilization := '  select round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1) from plaidmanager_account a  '; 
  s_sqlquery_current_balance := 'select sum(round(coalesce(a.current_balance,0),1)) from plaidmanager_account a  '; 

  s_sqlwhere := concat(' where 1 = 1 and lower(a.account_sub_type) = ''credit card'' and a.deleted_at is null and a.user_id =   ', app_user_id );   
  s_orderby := ' order by a.name '; 

  s_sqlquery_utilization := concat(s_sqlquery_utilization, s_sqlwhere); 
  s_sqlquery_current_balance := concat(s_sqlquery_current_balance, s_sqlwhere); 

  RAISE INFO 's_sqlstring utilization inside improve credit score : <%>', s_sqlquery_utilization;
    
  EXECUTE s_sqlquery_utilization into n_utilization_value;
  EXECUTE s_sqlquery_current_balance into n_current_balance;
  RAISE INFO 'n_jump_to_next_level : <%>', n_jump_to_next_level;
  RAISE INFO 'overall current balance : <%>', n_current_balance;

  IF n_utilization_value <=9 THEN 
    s_utilization_band :='excellent'; 
    s_utilization_message := ' (Excellent job btw :thumbsup:). '; 
    n_jump_to_next_level := abs(n_excellent_to_peak - n_utilization_value); 
  ELSIF n_utilization_value BETWEEN 9 AND 29 THEN 
    s_utilization_band :='great'; 
    s_utilization_message := ' (Great job :clap:). '; 
    n_jump_to_next_level := abs(n_very_good_to_excellent - n_utilization_value); 
  ELSIF n_utilization_value BETWEEN 29 AND 49 THEN
    s_utilization_band :='good'; 
    s_utilization_message := ' (Good job :ok_hand:). '; 
    n_jump_to_next_level := abs(n_good_to_very_good - n_utilization_value); 
  ELSIF n_utilization_value BETWEEN 49 AND 75 THEN 
    s_utilization_band :='fair'; 
    s_utilization_message := ' (Fair). '; 
    n_jump_to_next_level := abs(n_fair_to_good - n_utilization_value); 
  ELSIF n_utilization_value >75 THEN 
    s_utilization_band :='very high';
    s_utilization_message := ' (Heads up :exclamation:). '; 
    n_jump_to_next_level := abs(n_bad_to_fair - n_utilization_value); 
  ELSE 
    s_utilization_band :=NULL;
  END IF; 
  RAISE INFO 'n_jump_to_next_level : <%>', n_jump_to_next_level;
    
  n_payoff_to_improve := round(n_current_balance * (n_jump_to_next_level/100), 0); 

  RAISE INFO 'overall n_payoff_to_improve : <%>', n_payoff_to_improve;


  -- IF s_utilization_band = 'excellent' THEN 
  --   display_message := concat('Your current credit usage is ', n_utilization_value, '%', s_utilization_message, 'Paying off ', cast(n_payoff_to_improve as money), ' on your credit cards will move up your usage level and improve your credit score. Here are some additional recommendations for you..' );
  --   voice_message := concat('Your current utilization is ', n_utilization_value, '%. Paying off ', cast(n_payoff_to_improve as money), ' on your credit cards will move up your usage level and improve your credit score. Here are some additional recommendations for you..' );
  -- ELSIF s_utilization_band = 'great' THEN 
  --   display_message := concat('Your current utilization is ', n_utilization_value, '%', s_utilization_message, 'Secret Tip: Paying off ', cast(n_payoff_to_improve as money), ' on your credit cards will lead to a magical rise in your credit score. Here are some additional recommendations for you..' );
  --   voice_message := concat('Your current utilization is ', n_utilization_value, '%. Paying off ', cast(n_payoff_to_improve as money), ' on your credit cards will better your current utilization level and improve your credit score. Here are some additional recommendations for you..' );

  -- ELSIF s_utilization_band in ('good', 'fair', 'very high') THEN 
  --   display_message := concat('Your current credit usage is ', n_utilization_value, '%', s_utilization_message, 'Hint: Paying off ', cast(n_payoff_to_improve as money), ' on your credit cards will move up your usage level and improve your credit score. Here are some additional recommendations for you..' ); 
  --   voice_message := concat('Your current utilization is ', n_utilization_value, '%. Paying off ', cast(n_payoff_to_improve as money), ' on your credit cards will better your current utilization level and improve your credit score. Here are some additional recommendations for you..' );

  -- ELSE 
  --   display_message := null; 
  -- END IF;

  -- --RAISE INFO 'Display message : <%>', display_message;

  FOR r in (select * from plaidmanager_account where user_id = app_user_id and lower(account_sub_type) = 'credit card' and deleted_at is null) LOOP
    IF account_data_as_json IS NULL THEN 
      account_data_as_json := '[{';
    ELSE 
        account_data_as_json := concat(account_data_as_json, ',{');
    END IF; 
    RAISE INFO 'inside card reco plaidmanager_account for loop and r.current : <%>', r.current_balance;
    RAISE INFO 'inside card reco plaidmanager_account for loop and r.current : <%>', r.balance_limit;

    n_account_payoff_to_improve :=null; 
    n_account_jump_to_next_level := null;
    n_account_current_balance := round(coalesce(r.current_balance, 0), 1); 
    --n_account_utilization := round((r.current/coalesce(r.credit_limit,null) *100), 1); 
    n_account_utilization := round((r.current_balance/(CASE WHEN round(r.balance_limit) IS NULL THEN r.available_balance WHEN round(r.balance_limit) = 0 THEN r.available_balance ELSE r.balance_limit END) *100), 1); 
    RAISE INFO 'n_account_utilization: <%>', n_account_utilization;
    
    IF n_account_utilization <=9 THEN 
      n_account_jump_to_next_level := abs(n_excellent_to_peak - n_account_utilization); 
    ELSIF n_account_utilization BETWEEN 9 AND 29 THEN 
      n_account_jump_to_next_level := abs(n_very_good_to_excellent - n_account_utilization); 
    ELSIF n_account_utilization BETWEEN 29 AND 49 THEN
      n_account_jump_to_next_level := abs(n_good_to_very_good - n_account_utilization); 
    ELSIF n_account_utilization BETWEEN 49 AND 75 THEN 
      n_account_jump_to_next_level := abs(n_fair_to_good - n_account_utilization); 
    ELSIF n_account_utilization >75 THEN 
      n_account_jump_to_next_level := abs(n_bad_to_fair - n_account_utilization); 
    ELSE 
      n_account_jump_to_next_level :=NULL;
    END IF;  
    n_account_payoff_to_improve := round(n_account_current_balance * (n_account_jump_to_next_level/100), 0); 
    RAISE INFO 'inside for loop account current balance: <%>', n_account_current_balance;
    RAISE INFO 'inside loop n_account_jump_to_next_level: <%>', n_account_jump_to_next_level;
    RAISE INFO 'n_account_payoff_to_improve : <%>', n_account_payoff_to_improve; 
    n_total_account_payoff_to_improve := n_total_account_payoff_to_improve + n_account_payoff_to_improve;
    --RAISE INFO 'n_total_account_payoff_to_improve : <%>', n_total_account_payoff_to_improve; 
    BEGIN
      select distinct i.name, i.code, i.color_scheme from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i  where a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.plaidmanager_item_id = r.plaidmanager_item_id INTO s_institution_name, s_institution_id, s_color_scheme;  

    EXCEPTION WHEN OTHERS THEN 
      s_institution_name :=NULL; 
      s_institution_id := NULL;
      s_color_scheme :=NULL;
    END; 

    account_data_as_json := concat(account_data_as_json, '"institution_name": "', s_institution_name, '","color_scheme": "',s_color_scheme, '","institution_id": "', s_institution_id, '","name": "', r.name, '","payoff_value": "', cast(n_account_payoff_to_improve as money), '","account_id": "', r.account_id, '","payoff_amount": ', coalesce(n_account_payoff_to_improve, 0)   );

    IF display_notes IS NULL THEN 
     display_notes := concat(display_notes, s_account_message_filler_first_message, ' Pay off ', cast(n_account_payoff_to_improve as money), ' on your ', s_institution_name, ' ', r.name, ' to move up to the next utilization level'); 
    ELSE 
      display_notes := concat(display_notes, s_account_message_filler, ' Pay off ', cast(n_account_payoff_to_improve as money), ' on your ', s_institution_name, ' ', r.name, ' to move up to the next utilization level'); 

    END IF; 
    
    account_data_as_json := concat(account_data_as_json, '}'); 
  
  END LOOP;
  IF account_data_as_json IS NULL THEN 
    account_data_as_json := concat(account_data_as_json, '[]');
  ELSE 
    account_data_as_json := concat(account_data_as_json, ']'); 
  END IF; 

  display_notes := cast(n_total_account_payoff_to_improve as money);
  BEGIN 
    select first_name from users_user where id = app_user_id into s_user_nickname; 
  EXCEPTION WHEN OTHERS THEN 
    s_user_nickname := NULL;  
  END; 

  IF s_utilization_band = 'excellent' THEN 
    display_message := concat(s_user_nickname, ', paying off ', cast(n_total_account_payoff_to_improve as money), ' will decrease your credit usage and improve your credit score.' );
    voice_message := concat(s_user_nickname, ', paying off ', cast(n_total_account_payoff_to_improve as money), ' will decrease your credit usage and improve your credit score. ' );
  ELSIF s_utilization_band = 'great' THEN 
    display_message := concat(s_user_nickname, ', paying off ', cast(n_total_account_payoff_to_improve as money), ' will decrease your credit usage and improve your credit score.' );
    voice_message := concat(s_user_nickname, ', paying off ', cast(n_total_account_payoff_to_improve as money), ' will decrease your credit usage and improve your credit score. ' );
  ELSIF s_utilization_band in ('good', 'fair', 'very high') THEN 
    display_message := concat(s_user_nickname, ', paying off ', cast(n_total_account_payoff_to_improve as money), ' will decrease your credit usage and improve your credit score. ' );
    voice_message := concat(s_user_nickname, ', paying off ', cast(n_total_account_payoff_to_improve as money), ' will decrease your credit usage and improve your credit score. ' );
  ELSE 
    display_message := null; 
  END IF;

  --RAISE INFO 'Display message : <%>', display_message;

  --RAISE INFO 'Display notes : <%>', display_notes;
  --RAISE INFO 'improve credit score account json : <%>', account_data_as_json;

 EXCEPTION WHEN OTHERS THEN
  RAISE INFO 'Inside exception : <%>', app_user_id;
  display_message := NULL;
  display_notes := NULL;
  voice_message :=NULL; 
  account_data_as_json := NULL;

END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_improve_credit_score(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_message text, OUT display_notes text, OUT voice_message text, OUT account_data_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_how_can_i_save_money
-- Purpose: Function to provide tips on how to save money
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_how_can_i_save_money(p_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_message text, OUT display_notes text, OUT voice_message text)
AS $$

DECLARE
  s_sqlquery_string_for_interest_paid_value text := null;
  s_sqlquery_string_for_subscriptions_paid_value text := null;
  s_sqlquery_string_for_late_fees_paid_value text := null;
  s_sqlquery_string_for_foreign_transaction_fees_paid_value text := null;
  s_sqlquery_string_for_subscriptions_count text :=null;
  s_sqlquery_distinct_subscriptions text :=null;
  s_sqlwhere text := null;
  n_subscriptions_paid_value numeric; 
  n_subscription_count integer; 
  n_interest_paid_value numeric; 
  n_late_fees_paid_value numeric; 
  n_foreign_transaction_fees_paid_value numeric; 
  s_nickname text; 
  s_display_notes_filler text := '<br><br> :point_right: '; 
  s_display_notes_filler_first_message text := ':point_right: '; 
  s_institution_name text;
  s_distinct_subscriptions text;
  s_user_nickname text; 
 
BEGIN
-- 
  s_sqlquery_string_for_interest_paid_value := 'select cast(sum(t.amount) as money) from plaidmanager_transaction t, plaidmanager_account a where t.account_id = a.account_id and t.category_id in ( 15002000, 10000000, 10003000) and  a.deleted_at is null  and ';  
  s_sqlquery_string_for_subscriptions_paid_value := 'select cast(sum(t.amount) as money) from plaidmanager_transaction t, plaidmanager_account a where t.account_id = a.account_id and t.category_id in ( 18009000, 18030000, 18061000) and  a.deleted_at is null  and ';  
  s_sqlquery_string_for_subscriptions_count := 'select count(*) from plaidmanager_transaction t, plaidmanager_account a where t.account_id = a.account_id and t.category_id in ( 18009000, 18030000, 18061000) and  a.deleted_at is null  and ';  
  s_sqlquery_string_for_late_fees_paid_value := 'select cast(sum(t.amount) as money) from plaidmanager_transaction t, plaidmanager_account a where t.account_id = a.account_id and t.category_id in ( 10003000) and a.deleted_at is null  and ';  
  s_sqlquery_string_for_foreign_transaction_fees_paid_value := 'select cast(sum(t.amount) as money) from plaidmanager_transaction t, plaidmanager_account a where t.account_id = a.account_id and t.category_id in ( 10005000 ) and  a.deleted_at is null and ';  
  s_sqlquery_distinct_subscriptions := 'select string_agg(distinct t.name::text,''  '') from plaidmanager_transaction t, plaidmanager_account a where t.account_id = a.account_id and t.category_id in ( 18009000, 18030000, 18061000)  and  a.deleted_at is null and ';
  s_sqlwhere := concat(' a.user_id = ', p_user_id, ' and t.transaction_date >= current_date - 120 '); 

  s_sqlquery_string_for_interest_paid_value := concat (s_sqlquery_string_for_interest_paid_value, s_sqlwhere); 
  s_sqlquery_string_for_subscriptions_paid_value := concat (s_sqlquery_string_for_subscriptions_paid_value, s_sqlwhere); 
  s_sqlquery_string_for_subscriptions_count := concat (s_sqlquery_string_for_subscriptions_count, s_sqlwhere); 
  s_sqlquery_string_for_late_fees_paid_value := concat (s_sqlquery_string_for_late_fees_paid_value, s_sqlwhere); 
  s_sqlquery_string_for_foreign_transaction_fees_paid_value := concat (s_sqlquery_string_for_foreign_transaction_fees_paid_value, s_sqlwhere); 
  s_sqlquery_distinct_subscriptions := concat (s_sqlquery_distinct_subscriptions, s_sqlwhere); 

  RAISE INFO 's_sqlstring interest: <%>', s_sqlquery_string_for_interest_paid_value;
  RAISE INFO 's_sqlquery_string_for_subscriptions_paid_value: <%>', s_sqlquery_string_for_subscriptions_paid_value;
  RAISE INFO 's_sqlquery_string_for_late_fees_paid_value: <%>', s_sqlquery_string_for_late_fees_paid_value;
  RAISE INFO 's_sqlquery_string_for_subscriptions_count: <%>', s_sqlquery_string_for_subscriptions_count;
  RAISE INFO 's_sqlquery_string_for_foreign_transaction_fees_paid_value: <%>', s_sqlquery_string_for_foreign_transaction_fees_paid_value;
  RAISE INFO 's_sqlquery_distinct_subscriptions: <%>', s_sqlquery_distinct_subscriptions;
  
  EXECUTE s_sqlquery_string_for_interest_paid_value into n_interest_paid_value;
  EXECUTE s_sqlquery_string_for_subscriptions_paid_value into n_subscriptions_paid_value;
  EXECUTE s_sqlquery_string_for_late_fees_paid_value into n_late_fees_paid_value;
  EXECUTE s_sqlquery_string_for_foreign_transaction_fees_paid_value into n_foreign_transaction_fees_paid_value;
  EXECUTE s_sqlquery_string_for_subscriptions_count into n_subscription_count;
  EXECUTE s_sqlquery_distinct_subscriptions into s_distinct_subscriptions;


  BEGIN 
    select first_name from users_user where id = p_user_id into s_user_nickname; 
  EXCEPTION WHEN OTHERS THEN 
    s_user_nickname := NULL;  
  END; 
  IF (s_user_nickname IS NOT NULL) THEN 
    display_message:= concat(s_user_nickname, ' Here are some tips for you to save money by analyzing your connected accounts');
    voice_message:= concat(s_user_nickname, ', Here are some tips for you to save money by analyzing your connected accounts');
  ELSE 
    display_message := 'Here are some tips for you to save money by analyzing your connected accounts'; 
    voice_message := 'Here are some tips for you to save money by analyzing your connected accounts'; 
  END IF;   

  IF display_notes is NULL THEN 
    s_display_notes_filler := s_display_notes_filler_first_message;
  END IF;

  IF n_interest_paid_value IS NOT NULL THEN 
    display_notes := concat(display_notes, s_display_notes_filler, 'You have paid ', cast(n_interest_paid_value as money), ' towards interest payments in the past four months. Reducing your credit card balances is a great way to avoid charges towards interest'); 
     s_display_notes_filler := '<br><br> :point_right: '; 
  END IF; 
  IF n_subscriptions_paid_value IS NOT NULL THEN 
    --display_notes := concat(display_notes, s_display_notes_filler, 'You have paid ', cast(n_subscriptions_paid_value as money), ' towards ', n_subscription_count, ' subscriptions in the past four months. Review your current subscriptions (', s_distinct_subscriptions, ') to make sure you are using all of it'); 
    display_notes := concat(display_notes, s_display_notes_filler, 'You have paid ', cast(n_subscriptions_paid_value as money), ' towards subscriptions in the past four months. Review your current subscriptions (', s_distinct_subscriptions, ') to make sure you are using all of it'); 
    s_display_notes_filler := '<br><br> :point_right: '; 

  END IF;
  display_notes := concat(display_notes, s_display_notes_filler, 'Ask me prior to making a purchase so that I can recommend the best cards to use to maximize your cashback or rewards :stuck_out_tongue:'); 
  IF n_late_fees_paid_value IS NOT NULL THEN 
    display_notes := concat(display_notes, s_display_notes_filler, 'You have paid ', cast(n_late_fees_paid_value as money), ' towards late fees in the past four months. Paying your credit card minimum balance on time is a great way to avoid such charges'); 
    s_display_notes_filler := '<br><br> :point_right: '; 
  END IF;
  IF n_foreign_transaction_fees_paid_value IS NOT NULL THEN 
    display_notes := concat(display_notes, s_display_notes_filler, 'You have paid ', cast(n_foreign_transaction_fees_paid_value as money), ' as foreign transaction fee in the past four months. By using the right credit card which have 0% foreign transaction fee, you can avoid such charges'); 
    s_display_notes_filler := '<br><br> :point_right: '; 
  END IF;
  display_notes := concat(display_notes, s_display_notes_filler, 'Ask me for your spending bandwidth prior to make a purchase'); 

  --RAISE INFO 'Display notes : <%>', display_notes;
  --RAISE INFO 'Display message : <%>', display_message;
  --RAISE INFO 'Voice message : <%>', voice_message;

 EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', p_user_id;
  display_message := NULL;
  display_notes := NULL;
  voice_message :=NULL; 

END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_how_can_i_save_money(p_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_message text, OUT display_notes text, OUT voice_message text) OWNER TO evadev;

--******************--

--Function Name: get_credit_limit
-- Purpose: Function to get credit limit based on user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_credit_limit(
    IN app_user_id integer,
    IN d_from_date text,
    IN d_to_date text,
    IN s_amount text,
    IN s_plaid_account_name text,
    IN s_plaid_account_subtype text,
    IN s_plaid_institution_id text,
    IN s_category_levels_to_check text,
    IN s_category_level0 text,
    IN s_category_level1 text,
    IN s_category_level2 text,
    IN s_ending_number text,
    IN s_txn_biz_name text,
    OUT display_value text,
    OUT account_data_as_json text)
  RETURNS record AS
$BODY$

DECLARE
  r text;
  s_sqlquery_string_for_credit_limit text := null;
  s_sqlquery_string_for_account_json text :=null;
  s_sqlwhere text := null;
  s_orderby text := null;

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string_for_credit_limit := ' select cast(sum((a.balance_limit)) as money)  from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i '; 

    s_sqlquery_string_for_account_json := ' SELECT i.name as "institution_name", coalesce(i.color_scheme,''4A4A4A'') as "color_scheme", i.code as "institution_id", a.name as "name", a.official_name as "official_name",a.mask as "ending_number", initcap(a.account_sub_type) as "subtype" , (cast(a.balance_limit as money)) as "available_balance", (cast(a.current_balance as money)) as "current_balance", (cast(a.balance_limit as money)) as "credit_limit", round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1) as "utilization_as_value", (case when (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) <= 9 THEN ''Excellent'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 9 and 29 THEN ''Very Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 29 and 49 THEN ''Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 49 and 75 THEN ''Fair'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 75 and 100 THEN ''Very High'' ELSE ''Not Applicable'' END) as "utilizaton_band", concat(round(((a.current_balance/case a.balance_limit WHEN null THEN NULLIF(a.available_balance,0) WHEN 0 THEN NULLIF(a.available_balance,0) ELSE a.balance_limit END) *100),1) ,''%'') as "utilization_percent_as_text", a.account_id FROM plaidmanager_account a, plaidmanager_item item, plaidmanager_institutionmaster i '; 
    
    s_sqlwhere := concat(' where 1 = 1 and  lower(a.account_type) <> ''depository'' and a.account_sub_type in ( ''loan'', ''line of credit'', ''credit card'')  and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and a.user_id =   ', app_user_id );   
    s_orderby := ' order by a.name '; 

------

    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
  
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 

    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 

    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 
-------
    s_sqlquery_string_for_credit_limit := concat(s_sqlquery_string_for_credit_limit, s_sqlwhere); 
    s_sqlquery_string_for_account_json := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_account_json, s_sqlwhere, s_orderby , ') row' ); 

    RAISE INFO 's_sqlquery_string_for_credit_limit: <%>', s_sqlquery_string_for_credit_limit;
    RAISE INFO 's_sqlstring for account json <%>', s_sqlquery_string_for_account_json;

    EXECUTE s_sqlquery_string_for_credit_limit into display_value;
    EXECUTE s_sqlquery_string_for_account_json into account_data_as_json;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    account_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  account_data_as_json := NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION get_credit_limit(
    IN app_user_id integer,
    IN d_from_date text,
    IN d_to_date text,
    IN s_amount text,
    IN s_plaid_account_name text,
    IN s_plaid_account_subtype text,
    IN s_plaid_institution_id text,
    IN s_category_levels_to_check text,
    IN s_category_level0 text,
    IN s_category_level1 text,
    IN s_category_level2 text,
    IN s_ending_number text,
    IN s_txn_biz_name text,
    OUT display_value text,
    OUT account_data_as_json text)
  OWNER TO evadev;

--******************--

--Function Name: get_credit_card_payments
-- Purpose: Function to get credit card payments for the user
-- version: 0.0 - baseline version


CREATE OR REPLACE FUNCTION get_credit_card_payments(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_credit_card_payments text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by plc.category_level0';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 

    s_sqlquery_string_for_credit_card_payments := ' select cast(sum(abs(t.amount)) as money) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 
    s_sqlwhere := concat(' where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and t.category_id in (21005000, 16001000) and lower(a.account_type) <> ''depository'' and a.account_sub_type in ( ''credit card'') and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc ';

--------
    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 

    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_category_levels_to_check IS NOT NULL) THEN 
      IF s_category_levels_to_check = '0' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level0) =''', lower(s_category_level0), ''' '); 
      ELSIF s_category_levels_to_check = '1' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level1) =''', lower(s_category_level1), ''' '); 
      ELSIF s_category_levels_to_check = '2' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level2) =''', lower(s_category_level2), ''' '); 
    END IF; 

    END IF; 
    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 

    END IF; 

    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    s_sqlquery_string_for_credit_card_payments := concat(s_sqlquery_string_for_credit_card_payments, s_sqlwhere ); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    RAISE INFO 's_sqlquery_string_for_credit_card_payments  <%>', s_sqlquery_string_for_credit_card_payments;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;
    EXECUTE s_sqlquery_string_for_credit_card_payments into display_value;

  ELSE 
    RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_credit_card_payments(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;


--******************--


--******************--

--Function Name: get_debit_transactions
-- Purpose: Function to get debit transactions for the user
-- version: 0.0 - baseline version


CREATE OR REPLACE FUNCTION get_debit_transactions(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_debit_transactions text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by plc.category_level0';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 

    s_sqlquery_string_for_debit_transactions := ' select cast(sum(abs(t.amount)) as money) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 
    s_sqlwhere := concat(' where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and t.category_id in (21012001) and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc ';

--------
    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 

    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_category_levels_to_check IS NOT NULL) THEN 
      IF s_category_levels_to_check = '0' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level0) =''', lower(s_category_level0), ''' '); 
      ELSIF s_category_levels_to_check = '1' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level1) =''', lower(s_category_level1), ''' '); 
      ELSIF s_category_levels_to_check = '2' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level2) =''', lower(s_category_level2), ''' '); 
    END IF; 

    END IF; 
    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 

    END IF; 

    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    s_sqlquery_string_for_debit_transactions := concat(s_sqlquery_string_for_debit_transactions, s_sqlwhere ); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    RAISE INFO 's_sqlquery_string_for_debit_transactions  <%>', s_sqlquery_string_for_debit_transactions;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;
    EXECUTE s_sqlquery_string_for_debit_transactions into display_value;

  ELSE 
    RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_debit_transactions(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;


--******************--


--Function Name: get_transactions_json
-- Purpose: Function to build the transaction query and
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_transactions_json(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlwhere  text := null;
  s_orderby text := null;
  s_exception_sqlquery_string text :='select null ';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := 'select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", t.amount as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlwhere := concat('  where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.user_id = ', app_user_id);
    s_orderby := ' order by t.transaction_date desc '; 

    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
    END IF; 
    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF;     
    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 
    END IF; 

    IF ((s_category_levels_to_check IS NOT NULL) and (s_txn_biz_name IS NULL)) THEN 
      IF s_category_levels_to_check = '0' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level0) =''', lower(s_category_level0), ''' '); 
      ELSIF s_category_levels_to_check = '1' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level1) =''', lower(s_category_level1), ''' '); 
      ELSIF s_category_levels_to_check = '2' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level2) =''', lower(s_category_level2), ''' '); 
      END IF; 

    END IF; 

    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number, ''' ' ); 
    END IF; 

    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 

    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    RAISE INFO 's_sqlstring: <%>', s_sqlquery_string;
    RAISE INFO 's_sqlwhere: <%>', s_sqlwhere;

    EXECUTE s_sqlquery_string into transaction_output_as_json;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_transactions_json(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_credit_card_transactions
-- Purpose: Function to build the transaction query for credit card transactions

CREATE OR REPLACE FUNCTION get_credit_card_transactions(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string_credit_card_transaction text := null;
  s_sqlwhere  text := null;
  s_orderby text := null;
  s_exception_sqlquery_string text :='select null ';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string_credit_card_transaction := 'select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlwhere := concat ( '   where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and a.account_type in (''credit'') and t.user_id =   ', app_user_id);
    s_orderby := ' order by t.transaction_date desc '; 
    --RAISE INFO 'Before building where: <%>', s_sqlwhere; 

    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 
    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    
    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 
    END IF; 

    IF ((s_category_levels_to_check IS NOT NULL) and (s_txn_biz_name IS NULL)) THEN 
      IF s_category_levels_to_check = '0' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level0) =''', lower(s_category_level0), ''' '); 
      ELSIF s_category_levels_to_check = '1' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level1) =''', lower(s_category_level1), ''' '); 
      ELSIF s_category_levels_to_check = '2' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level2) =''', lower(s_category_level2), ''' '); 
      END IF; 

    END IF; 

    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number, ''' ' ); 
    END IF; 

    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 

    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

    s_sqlquery_string_credit_card_transaction := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_credit_card_transaction, s_sqlwhere, s_orderby , ') row' ); 
    RAISE INFO 's_sqlquery_string_credit_card_transaction: <%>', s_sqlquery_string_credit_card_transaction;
    RAISE INFO 's_sqlwhere: <%>', s_sqlwhere;

    EXECUTE s_sqlquery_string_credit_card_transaction into transaction_output_as_json;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_credit_card_transactions(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT transaction_output_as_json text) OWNER TO evadev;


--******************--

--Function Name: get_card_recommendations
-- Purpose: Function to get card recommendations for a purchasing scenario
-- version: 0.0 - baseline version
-- version 0.1 - added s_institution_name to store the institution name in the 

CREATE OR REPLACE FUNCTION get_card_recommendations(p_user_query_id IN integer, p_user_id IN integer, user_query IN text, s_amount IN text, OUT card_reco_data_as_json text)
AS $$

DECLARE
  r record;
  s record; 
  t record; 
  s_scenario text; 
  s_sqlquery_string text := null;
  s_sqlwhere text := null;
  n_weighted_average_value_for_account numeric := 0; 
  n_amount numeric :=0; -- to convert s_amount into numeric
  n_approx_amount numeric; 
  n_estimated_reward_value numeric :=0;
  b_user_amount boolean := TRUE; 
  s_account_messages_summary text; 
  s_account_break_line text :='<br>';
  s_account_message_filler text := '<br> :point_right: '; 
  s_account_message_point_right text := ':point_right: '; 
  s_double_break_line text :='<br><br>';
  n_card_type_debit_wt numeric;
  n_card_type_credit_wt numeric;  
  s_reward_type text;
  n_value_for_each_dollar_wt numeric;
  n_reward_points_multiplier_wt numeric;   
  n_credit_utilization_wt numeric;
  n_credit_score_wt numeric;
  n_travel_insurance_available_wt numeric;
  n_priority_boarding_available_wt numeric;  
  n_car_rental_liability_insurance_available_wt numeric;
  n_lost_baggage_insurance_available_wt numeric;
  score_credit_card numeric;
  score_debit_card numeric;
  b_goal_credit_score_improve_flag boolean; 
  b_goal_maximize_rewards_flag boolean; 
  score_excellent numeric :=1; 
  score_verygood numeric :=0.8;
  score_good numeric :=0.6;
  score_fair numeric :=0.4;
  score_bad numeric :=0.2;
  score_notapplicable numeric :=0;
  score_mid_point numeric := 0.5;
  score_debit_utilization numeric; 
  n_plaid_account_utilization numeric; 
  s_card_id integer;
  s_card_name text;
  s_card_type text;
  s_card_issuer text;
  s_issuing_bank_name  text;
  s_card_small_image_file_name text;
  s_card_large_image_file_name text;
  s_card_bg_color text;
  s_query_results_id text; 
  s_query_results_id_for_update text; 
  n_max_weighted_average_value_for_account numeric; 
  n_range numeric; 
  n_total_thumbs_up numeric; 
  s_reward_category_name text;  
  s_airline_name_from_query text; 
  s_matched_airline_keyword  text;
  s_hotel_name_from_query text;
  s_matched_hotel_keyword  text;
  s_biz_name  text;
  s_matched_biz_name_keyword text;
  s_institution_name text; 
  s_institution_color text; 
  s_institution_id text;

BEGIN

  BEGIN
    IF (s_amount IS NULL) THEN 
      n_amount := 0;
      b_user_amount :=FALSE;
    ELSE   
      n_amount := to_number (s_amount, '999999.99');
      --RAISE INFO 'inside amount conversion : <%>', s_amount;
      b_user_amount :=TRUE;
    END IF;   
  EXCEPTION WHEN OTHERS THEN 
    n_amount := 0;
    b_user_amount :=FALSE; 
  END; 
  IF (n_amount = 0) THEN 
    n_approx_amount := 100; 
    b_user_amount := FALSE; 
  END IF; 
  --RAISE INFO 'right after amount conversion : <%>', s_amount;

  BEGIN
    --SELECT goal_credit_score_improve_flag, goal_maximize_rewards_flag from users_user where app_user_id = p_user_id INTO b_goal_credit_score_improve_flag, b_goal_maximize_rewards_flag;
    b_goal_credit_score_improve_flag := 'true'; 
    b_goal_maximize_rewards_flag :='true';

  EXCEPTION WHEN OTHERS THEN 
    b_goal_credit_score_improve_flag :=NULL; 
    b_goal_maximize_rewards_flag :=NULL; 
  END; 
  --RAISE INFO 'right before scenario setting : <%>', s_amount;

  IF (b_goal_credit_score_improve_flag IS TRUE) AND (b_goal_maximize_rewards_flag IS TRUE) THEN 
    s_scenario := 'one_or_more_card_attached_linked_accounts_both_goals';
    score_debit_utilization := score_mid_point; 
  ELSIF (b_goal_credit_score_improve_flag IS TRUE) AND (b_goal_maximize_rewards_flag IS FALSE) THEN 
    s_scenario := 'one_or_more_card_attached_linked_improve_credit_score_wt'; 
    score_debit_utilization := score_good;  
  ELSIF (b_goal_credit_score_improve_flag IS FALSE) AND (b_goal_maximize_rewards_flag IS TRUE) THEN 
    s_scenario := 'one_or_more_card_attached_linked_accounts_maximize_benefits'; 
    score_debit_utilization := score_fair;  
  ELSE 
    s_scenario := 'one_or_more_card_attached_linked_accounts_both_goals'; 
    score_debit_utilization := score_mid_point; 
  END IF; 
  --RAISE INFO 'iright after goals select : <%>', s_amount;

-- Logic for standalone app
/*
    BEGIN 
      select count(*) from user_connected_cards (table to be created) where user_id = p_user_id  into n_count; 
    EXCEPTION 
      WHEN OTHERS THEN 
        n_count :=0;
     END     
    IF n_count = 0 THEN 
      s_scenario :='no_cards_attached'; 
      score_debit_utilization := score_mid_point; 
    ELSIF (n_count >0) AND (IF goal_credit_score_improve_flag IS TRUE AND goal_maximize_rewards_flag IS TRUE) THEN 
      s_scenario := 'one_or_more_card_attached_no_linked_accounts_both_goals';
      score_debit_utilization := score_mid_point; 
    ELSIF (n_count >0) AND (goal_credit_score_improve_flag IS TRUE AND goal_maximize_rewards_flag IS FALSE) THEN 
      s_scenario := 'one_or_more_card_attached_no_linked_accounts_improve_credit_score_wt'; 
      score_debit_utilization := score_good;  
    ELSIF (n_count >0) AND (goal_credit_score_improve_flag IS FALSE AND goal_maximize_rewards_flag IS TRUE) THEN 
      s_scenario := 'one_or_more_card_attached_no_linked_accounts_maximize_benefits'; 
      score_debit_utilization := score_fair;  
    ELSE 
          s_scenario := 'one_or_more_card_attached_no_linked_accounts_both_goals'; 
    END IF;    

*/
  BEGIN
    SELECT coalesce(card_type_debit_wt, 0), coalesce(card_type_credit_wt, 0), coalesce(value_for_each_dollar_wt, 0), coalesce(reward_points_multiplier_wt, 0), coalesce(credit_utilization_wt, 0), coalesce(credit_score_wt, 0), coalesce(travel_insurance_available_wt, 0), coalesce(priority_boarding_available_wt, 0), coalesce(car_rental_liability_insurance_available_wt, 0), coalesce(lost_baggage_insurance_available_wt, 0) FROM configure_scenariocriteriaweightage WHERE name = s_scenario INTO n_card_type_debit_wt,n_card_type_credit_wt,n_value_for_each_dollar_wt,n_reward_points_multiplier_wt,n_credit_utilization_wt, n_credit_score_wt, n_travel_insurance_available_wt,n_priority_boarding_available_wt,n_car_rental_liability_insurance_available_wt, n_lost_baggage_insurance_available_wt; 
    
  EXCEPTION WHEN OTHERS THEN 

  END; 
  --RAISE INFO 'right after getting all weights : <%>', s_amount;
  BEGIN 
    select * from get_reward_category_info_from_user_query(user_query) into s_reward_category_name, s_airline_name_from_query, s_matched_airline_keyword, s_hotel_name_from_query,  s_matched_hotel_keyword ,s_biz_name , s_matched_biz_name_keyword;
  EXCEPTION WHEN OTHERS THEN 
      s_reward_category_name := NULL; 
      s_airline_name_from_query := NULL; 
      s_matched_airline_keyword := NULL;  
      s_hotel_name_from_query := NULL; 
      s_matched_hotel_keyword := NULL; 
      s_biz_name := NULL; 
      s_matched_biz_name_keyword := NULL; 
  END; 
  --RAISE INFO 'right after get_reward_category_info_from_user_query s_reward_category_name : <%>', s_reward_category_name;
  --RAISE INFO 'right after get_reward_category_info_from_user_query s_airline_name_from_query : <%>', s_airline_name_from_query;
  --RAISE INFO 'right after get_reward_category_info_from_user_query s_matched_airline_keyword : <%>', s_matched_airline_keyword;
  --RAISE INFO 'right after get_reward_category_info_from_user_query s_hotel_name_from_query : <%>', s_hotel_name_from_query;
  --RAISE INFO 'right after get_reward_category_info_from_user_query s_matched_hotel_keyword : <%>', s_matched_hotel_keyword;
  --RAISE INFO 'right after get_reward_category_info_from_user_query s_biz_name : <%>', s_biz_name;
  --RAISE INFO 'right after get_reward_category_info_from_user_query s_matched_biz_name_keyword : <%>', s_matched_biz_name_keyword;

  -- Logic for standalone app - FOR r in (select * from user_connected_accounts where app_user_id = p_user_id) LOOP
  FOR r in select * from plaidmanager_account where deleted_at is null and user_id = p_user_id and account_sub_type in ('checking', 'credit card') LOOP
      -- Logic for standalone app - change where condition to 'where card_id = r.card_id'
      --RAISE INFO 'right inside the plaid accounts for loop : <%>', r.name;
      -- #1 credit vs debit
      score_credit_card :=1; 
      score_debit_card :=1; 
      n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + ((n_card_type_debit_wt * score_credit_card) + (n_card_type_credit_wt * score_debit_card)); 

      -- #2 value for each dollar
      -- --RAISE INFO 'right before value for each dollar : <%>', to_char(n_weighted_average_value_for_account, '99999.99');
      -- technically the value for each dollar should be checked inside the card master loop. removing it for now 
      --n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_value_for_each_dollar_wt;
      --RAISE INFO 'right after value for each dollar : <%>', to_char(n_weighted_average_value_for_account, '99999.99');
      -- #3 check if the plaid account is available in card master to calculate the cashback or reward points
     /* FOR s in select * from configure_cardmaster where plaid_account_name = r.account_name LOOP 
          --RAISE INFO 'right inside card master for loop: <%>', r.account_name;
          s_card_id := s.id;
          s_card_name  := s.card_name;
          s_card_type  := s.card_type;
          s_card_issuer  := s.card_issuer;
          s_issuing_bank_name  := s.issuing_bank_name;
          s_card_small_image_file_name  := s.card_small_image_file_name;
          s_card_large_image_file_name  := s.card_large_image_file_name ;
          s_card_bg_color  := s.card_bg_color;
          s_reward_type  := s.reward_type;

          --RAISE INFO 'right after variable assignments : <%>', s_reward_type;
          IF s_reward_category_name = 'gas_reward' THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.gas_reward, 0); 
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.gas_reward/100)), 2); 
              
              IF s.reward_type = 'cashback' THEN
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.gas_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.gas_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.gas_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.gas_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.gas_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.gas_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF; 
         
          ELSIF s_reward_category_name = 'grocery_reward' THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.grocery_reward, 0); 
             IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.grocery_reward/100)),2); 
              
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.grocery_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.grocery_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.grocery_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.grocery_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.grocery_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.grocery_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF; 
         
          ELSIF s_reward_category_name = 'supermarket_reward' THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.supermarket_reward, 0); 
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.supermarket_reward/100)), 2); 
              
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.supermarket_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.supermarket_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.supermarket_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.supermarket_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.supermarket_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.supermarket_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF; 
         
          ELSIF s_reward_category_name = 'department_store_reward' THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.department_store_reward, 0); 
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.department_store_reward/100)),2); 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.department_store_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.department_store_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.department_store_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.department_store_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.department_store_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.department_store_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF; 
         
          ELSIF s_reward_category_name = 'movies_reward' THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.movies_reward, 0); 
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.movies_reward/100)),2); 
              
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.movies_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.movies_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.movies_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.movies_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.movies_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.movies_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF; 
        
          ELSIF s_reward_category_name = 'wholesale_club_reward' THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.wholesale_club_reward, 0); 
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.wholesale_club_reward/100)),2); 
              
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.wholesale_club_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.wholesale_club_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.wholesale_club_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.wholesale_club_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.wholesale_club_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.wholesale_club_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF; 
        
          ELSIF s_reward_category_name = 'restaurants_reward' THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.restaurants_reward, 0); 
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.restaurants_reward/100)),2); 
              
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.restaurants_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.restaurants_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.restaurants_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.restaurants_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.restaurants_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.restaurants_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF; 
        
          ELSIF s_reward_category_name = 'rental_car_reward' THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.rental_car_reward, 0); 
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.rental_car_reward/100)),2); 
              
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.rental_car_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.rental_car_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.rental_car_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.rental_car_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.rental_car_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.rental_car_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF; 
        
          ELSIF s_reward_category_name = 'airline_reward' THEN 
            IF (lower(s.airline_name) = lower(s_airline_name_from_query)) THEN
               n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.airline_reward, 0); 
            END IF;
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.airline_reward/100)),2); 
              
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.airline_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.airline_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.airline_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.airline_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.airline_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.airline_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF;     

          ELSIF s_reward_category_name = 'hotel_reward' THEN 
            IF (lower(s.hotel_name) = lower(s_hotel_name_from_query)) THEN
              n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.hotel_reward, 0); 
            END IF;
             IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.hotel_reward/100)),2); 
              
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.hotel_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.hotel_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.hotel_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.hotel_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.hotel_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.hotel_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF;         

          ELSIF s_reward_category_name = 'all_category_reward' THEN 
            --RAISE INFO 'inside the all category else  : <%>', s_reward_category_name;

            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account,0) + n_reward_points_multiplier_wt * coalesce(s.all_category_reward, 0);              
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.all_category_reward/100)),2); 
              

              IF s.reward_type = 'cashback' THEN 
                --RAISE INFO 'inside cashback if   : <%>', s_reward_category_name;

                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF;         

          ELSE 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + n_reward_points_multiplier_wt * coalesce(s.all_category_reward, 0);  
            IF (b_user_amount IS TRUE) THEN 
              n_estimated_reward_value := round((coalesce(n_amount, 0) * (s.all_category_reward/100)),2); 

              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated cash back is $', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated reward points is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Your estimated miles is ', n_estimated_reward_value); 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;     
            ELSIF (b_user_amount IS FALSE) THEN 
              IF s.reward_type = 'cashback' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, '% cash back on eligible purchases'); 
              ELSIF  s.reward_type = 'points' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, 'X reward points on eligible purchases');
              ELSIF s.reward_type = 'airline_miles' THEN 
                s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, s.all_category_reward, 'X miles on eligible purchases'); 
              ELSE 
              END IF;    
            END IF;                           
          END IF; 
          -- #5 
          IF s.travel_accident_insurance_available IS TRUE THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + (n_travel_insurance_available_wt * score_excellent);  
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Travel Accident Insurance available'); 
          ELSE 
            n_weighted_average_value_for_account := n_weighted_average_value_for_account + n_travel_insurance_available_wt * score_notapplicable;  
          END IF; 
          -- #6
          IF s.priority_boarding IS TRUE THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + (n_priority_boarding_available_wt * score_excellent);  
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Priority Boarding available'); 
          ELSE 
            n_weighted_average_value_for_account := n_weighted_average_value_for_account + n_priority_boarding_available_wt * score_notapplicable;  
          END IF; 
          -- #7 
          IF s.car_rental_insurance_available IS TRUE THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + (n_car_rental_liability_insurance_available_wt * score_excellent);  
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Rental Car Insurance available'); 
          ELSE 
            n_weighted_average_value_for_account := n_weighted_average_value_for_account + n_car_rental_liability_insurance_available_wt * score_notapplicable;  
          END IF; 
          -- #8
          IF s.lost_baggage_covered IS TRUE THEN 
            n_weighted_average_value_for_account := coalesce(n_weighted_average_value_for_account, 0) + (n_lost_baggage_insurance_available_wt * score_excellent);  
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_filler, 'Lost Baggage Insurance available'); 
          ELSE 
            n_weighted_average_value_for_account := n_weighted_average_value_for_account + n_lost_baggage_insurance_available_wt * score_notapplicable;  
          END IF; 
      END LOOP; 
*/
      -- #4 credit utilization 
      --RAISE INFO 'before IF printing subtype : <%>', r.account_sub_type;

      IF r.account_sub_type = 'credit card' THEN 
        BEGIN
          select round(((current_balance/coalesce(balance_limit,1)) *100),1) from plaidmanager_account  where account_id = r.account_id into n_plaid_account_utilization; 
          --RAISE INFO 'utilization : <%>', to_char(n_plaid_account_utilization, '99999.99');
          IF n_plaid_account_utilization < 9 THEN 
            n_weighted_average_value_for_account :=n_weighted_average_value_for_account + (n_credit_utilization_wt * score_excellent); 
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your current credit usage on this card is Excellent (', n_plaid_account_utilization, '%)! :clap:', s_account_break_line); 
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your available balance on this card is ', cast(r.available_balance as money)); 
          ELSIF (n_plaid_account_utilization > 9 ) AND (n_plaid_account_utilization < 29) THEN
            n_weighted_average_value_for_account :=n_weighted_average_value_for_account + (n_credit_utilization_wt * score_verygood);  
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your current credit usage on this card is Great (', n_plaid_account_utilization, '%)! :thumbsup:', s_account_break_line); 
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your available balance on this card is ', cast(r.available_balance as money)); 
          ELSIF (n_plaid_account_utilization > 29 ) AND (n_plaid_account_utilization < 49) THEN
            n_weighted_average_value_for_account :=n_weighted_average_value_for_account + (n_credit_utilization_wt * score_good); 
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your current credit usage on this card is Good (', n_plaid_account_utilization, '%) :ok_hand:', s_account_break_line); 
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your available balance on this card is ', cast(r.available_balance as money)); 
          ELSIF (n_plaid_account_utilization > 49 ) AND (n_plaid_account_utilization < 75) THEN
            n_weighted_average_value_for_account :=n_weighted_average_value_for_account + (n_credit_utilization_wt * score_fair); 
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your current credit usage on this card is Fair (', n_plaid_account_utilization, '%)', s_account_break_line);
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your available balance on this card is ', cast(r.available_balance as money));  
          ELSIF (n_plaid_account_utilization > 75 ) AND (n_plaid_account_utilization <= 100) THEN
            n_weighted_average_value_for_account :=n_weighted_average_value_for_account + (n_credit_utilization_wt * score_bad); 
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Heads up! Your current credit usage on this card is quite high (', n_plaid_account_utilization, '%) :exclamation:', s_account_break_line);
            s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your available balance on this card is ', cast(r.available_balance as money));  
          ELSE
            n_weighted_average_value_for_account :=n_weighted_average_value_for_account + (n_credit_utilization_wt * score_notapplicable); 
          END IF; 
        EXCEPTION WHEN OTHERS THEN 
            n_weighted_average_value_for_account :=n_weighted_average_value_for_account + (n_credit_utilization_wt * score_notapplicable); 
        END; 
      ELSIF r.account_sub_type = 'checking' THEN 
        n_weighted_average_value_for_account :=n_weighted_average_value_for_account + (n_credit_utilization_wt * score_debit_utilization); 
        s_account_messages_summary :=  concat(s_account_messages_summary, s_account_message_point_right, 'Your available balance on this account is ', cast(r.available_balance as money)); 
      ELSE 
        n_weighted_average_value_for_account :=n_weighted_average_value_for_account + (n_credit_utilization_wt * score_notapplicable); 
      END IF; 
      --RAISE INFO 'right after 4th check for credit utlizaion : <%>', to_char(n_weighted_average_value_for_account, '99999.99');
      --RAISE INFO 'message summary : <%>', s_account_messages_summary;
      -- get the institution name and institution color
      BEGIN 
        SELECT i.name, coalesce(i.color_scheme,'4A4A4A'), i.code from plaidmanager_account a, plaidmanager_item item, plaidmanager_institutionmaster i 
        where  1 = 1 and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.account_id = r.account_id INTO s_institution_name, s_institution_color, s_institution_id;
      EXCEPTION WHEN OTHERS THEN 
        s_institution_name  :=null; 
        s_institution_color :=null; 
        s_institution_id :=null;

      END;  

      IF s_card_bg_color IS NULL THEN 
        s_card_bg_color :=s_institution_color; 
      END IF; 

      -- insert into users_cardrecommendationqueryresult table for every connected account or card
      BEGIN 
        INSERT into users_cardrecommendationqueryresult (query_id, user_id, card_id, card_name, card_type, card_issuer, issuing_bank_name, card_small_image_file_name, card_large_image_file_name, card_bg_color, reward_type, amount, estimated_reward_value, messages_summary, weighted_average_value_for_account, plaid_account_id, plaid_account_name, plaid_institution_id, institution_name, plaid_account_subtype,plaid_ending_number, created_at, updated_at) values (p_user_query_id, p_user_id, s_card_id, s_card_name, s_card_type, s_card_issuer, s_issuing_bank_name, s_card_small_image_file_name, s_card_large_image_file_name, s_card_bg_color, s_reward_type, n_amount, n_estimated_reward_value, s_account_messages_summary, n_weighted_average_value_for_account, r.account_id, r.name, s_institution_id, s_institution_name, r.account_sub_type, r.mask, now(), now() ) RETURNING id INTO s_query_results_id; 
      --RAISE INFO 'inserted into card recommendation query results : <%>', s_query_results_id;
    
      EXCEPTION WHEN OTHERS THEN 
          --RAISE INFO 'inside the card recommendation inser : <%>', s_query_results_id;
          s_query_results_id :=NULL;
      END; 
      s_card_id := NULL;
      s_card_name  := NULL;
      s_card_type  := NULL;
      s_card_issuer  := NULL;
      s_issuing_bank_name  := NULL; 
      s_card_small_image_file_name  := NULL;
      s_card_large_image_file_name  := NULL ;
      s_card_bg_color  := NULL;
      s_reward_type  := NULL;
      s_account_messages_summary :=NULL;
      n_estimated_reward_value := 0;
      n_weighted_average_value_for_account :=0;
  END LOOP;

  --Now run through the card_recommendation_query_results table for the query id to get the 
  BEGIN
    --RAISE INFO 'inside the loop of card reco query resuts table : <%>', to_char(n_weighted_average_value_for_account, '99999.99');

    select max(weighted_average_value_for_account) from users_cardrecommendationqueryresult WHERE query_id = p_user_query_id into n_max_weighted_average_value_for_account; 
    --RAISE INFO 'checking max of weighted_average_value_for_account : <%>', to_char(n_max_weighted_average_value_for_account, '99999.99');

  EXCEPTION WHEN OTHERS THEN 
    n_max_weighted_average_value_for_account :=1;
  END;

  FOR t in select * from users_cardrecommendationqueryresult where query_id = p_user_query_id LOOP
    n_range := (t.weighted_average_value_for_account/n_max_weighted_average_value_for_account)*100; 
    --RAISE INFO 'inside the for loop of card reco query resuts table : <%>', to_char(n_range, '99999.99');
    IF (n_range >=0) and (n_range <=20) THEN 
      n_total_thumbs_up := 1; 
    ELSIF  (n_range >20) and (n_range <=40) THEN 
      n_total_thumbs_up := 2; 
    ELSIF  (n_range >40) and (n_range <=60) THEN 
      n_total_thumbs_up := 3; 
    ELSIF  (n_range >60) and (n_range <=80) THEN 
      n_total_thumbs_up := 4; 
    ELSIF  (n_range >80) and (n_range <=100) THEN 
      n_total_thumbs_up := 5; 
    ELSE 
      n_total_thumbs_up := 1; 
    END IF;
    --RAISE INFO 'after thumbs up calc : <%>', to_char(n_total_thumbs_up, '99999.99');

  BEGIN
    UPDATE users_cardrecommendationqueryresult SET total_thumbs_up = n_total_thumbs_up WHERE id = t.id RETURNING id into s_query_results_id_for_update; 
    --RAISE INFO 'successfuly updated : <%>', s_query_results_id_for_update;
    n_total_thumbs_up :=null;
    n_range :=null;
    
  EXCEPTION WHEN OTHERS THEN 

  END; 

  END LOOP;
--select row_number() over (order by amount desc) as rank, * from plaidmanager_transaction 
  
  s_sqlquery_string :=concat('select row_number() over (order by weighted_average_value_for_account desc) as rank, total_thumbs_up, (CASE WHEN total_thumbs_up = 5 THEN ''Recommended'' WHEN  total_thumbs_up = 4 THEN '' '' WHEN total_thumbs_up = 3 THEN '' '' WHEN total_thumbs_up = 2 THEN '' '' WHEN total_thumbs_up = 1 THEN '' '' ELSE '' '' END) as thumbs_up_display_text, card_bg_color as "color_scheme", plaid_institution_id as institution_id, institution_name, plaid_account_name as name, plaid_ending_number as ending_number, initcap(plaid_account_subtype) as subtype, plaid_account_id as account_id, coalesce(messages_summary, '''') as notes, query_id, user_id, card_id, card_name, card_type, card_issuer, card_small_image_file_name, card_large_image_file_name, reward_type, amount, estimated_reward_value,  weighted_average_value_for_account from users_cardrecommendationqueryresult where query_id = ', p_user_query_id, ' order by weighted_average_value_for_account desc '); 
  s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string,  ') row' ); 
  --RAISE INFO 'ssql string : <%>', s_sqlquery_string;
  EXECUTE s_sqlquery_string into card_reco_data_as_json;
  --RAISE INFO 'card reco json : <%>', card_reco_data_as_json;


EXCEPTION WHEN OTHERS THEN  --main body exception
  RAISE INFO 'Sorry, Something went wrong <%>', null;

END;   

$$  LANGUAGE plpgsql;

ALTER FUNCTION get_card_recommendations(p_user_query_id IN integer, p_user_id IN integer, user_query IN text, s_amount IN text, OUT card_reco_data_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_interest_paid
-- Purpose: Function to know how much interest user has paid 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_interest_paid(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_interest_paid_value text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by t.category_id';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlquery_string_for_interest_paid_value := ' select cast(sum(abs(t.amount)) as money) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 
    s_sqlwhere := concat('  where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0  and t.category_id in ( 15002000, 10000000, 10003000) and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc '; 

--------
    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 
    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number, ''' ' ); 
    END IF; 
    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 
----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    s_sqlquery_string_for_interest_paid_value := concat(s_sqlquery_string_for_interest_paid_value, s_sqlwhere ); 

    --RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    --RAISE INFO 's_sqlquery_string_for_interest_paid_value  <%>', s_sqlquery_string_for_interest_paid_value;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;
    EXECUTE s_sqlquery_string_for_interest_paid_value into display_value;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_interest_paid(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_last_thing_bought
-- Purpose: Function to build the spending by categort
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_last_thing_bought(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_spend_check_value text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by plc.category_level0';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := 'select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlwhere := concat('  where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0  and plc.category_level0 not in (''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'', ''Service'') and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc limit 1 '; 

--------
    IF (s_plaid_account_name IS NOT NULL) THEN
      s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_txn_biz_name IS NOT NULL) THEN
      s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 

    END IF; 
    IF (s_ending_number IS NOT NULL) THEN
      s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 
    IF (s_plaid_account_subtype IS NOT NULL) THEN
      s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
      s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 
----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 

    --RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_last_thing_bought(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_last_visit
-- Purpose: Function to get information on when the user visited a place last
-- version: 0.0 - baseline version


CREATE OR REPLACE FUNCTION get_last_visit(p_user_query_text IN text, app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_type IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_last_visit text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by plc.category_level0';
  s_alt_biz_name text; 
  s_sql_count_txn text;
  n_txn_count integer;

BEGIN
  RAISE INFO 's_txn_biz_name  <%>', s_txn_biz_name;

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string_for_last_visit := ' select (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 9),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,9), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlwhere := concat(' where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %'' and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0  and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc limit 5 '; 

--

--SELECT regexp_replace(p_query, '^.* ', '')

--------
    IF (s_txn_biz_name IS NOT NULL) THEN
      --kg: changed = to like for better pattern match to business 3/27
      s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 

    ELSE 
      -- first check the last two words and if not, just go by the last word
      -- this is for getting last word
      BEGIN 
        SELECT SUBSTRING(p_user_query_text FROM '\w+\W+\w+$') INTO s_alt_biz_name; 

        s_sql_count_txn:= concat('select count(*) from plaidmanager_transaction t, plaidmanager_account a where t.account_id = a.account_id and a.deleted_at is null and lower (t.name) like ''%',lower(s_alt_biz_name), '%''', ' and a.user_id = ', user_id);

        EXECUTE s_sql_count_txn into n_txn_count; 

        IF (n_txn_count = 0) or (n_txn_count is NULL) THEN 
          BEGIN 
            SELECT regexp_replace(p_user_query_text, '^.* ', '') INTO s_alt_biz_name; 
          EXCEPTION WHEN OTHERS THEN 
            s_alt_biz_name:=null; 
          END; 
          s_sql_count_txn:= concat('select count(*) from plaidmanager_transaction t, plaidmanager_account a where t.account_id = a.account_id and a.deleted_at is null and lower (t.name) like ''%',lower(s_alt_biz_name), '%''', ' and a.user_id = ', user_id);
          RAISE INFO 's_sql_count_txn  <%>', s_sql_count_txn;
          EXECUTE s_sql_count_txn into n_txn_count;

        END IF; 
        IF n_txn_count > 0 THEN 
          s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_alt_biz_name), '%'' '); 

        ELSE 
          s_sqlwhere := concat(s_sqlwhere, ' and 1 = 2 '); 
        END IF; 
      EXCEPTION WHEN OTHERS THEN 
        s_alt_biz_name:=null; 
      END; 
      --RAISE INFO 'n txn count  <%>', n_txn_count;
      --RAISE INFO 's_alt_biz_name  <%>', s_alt_biz_name;

    END IF; 
----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    s_sqlquery_string_for_last_visit := concat(s_sqlquery_string_for_last_visit, s_sqlwhere, s_orderby ); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    RAISE INFO 's_sqlquery_string_for_last_visit  <%>', s_sqlquery_string_for_last_visit;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;
    EXECUTE s_sqlquery_string_for_last_visit into display_value;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_last_visit(p_user_query_text IN text, app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_type IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_monthly_average_spending
-- Purpose: Function to get monthly average spending 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_monthly_average_spending(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string_for_monthly_average_spending text := null;
  s_sqlwhere text := null;
  s_groupby text := ' group by 1 ';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string_for_monthly_average_spending := ' select to_char(date_trunc(''month'', t.transaction_date), ''YYYY-MM'') as "category", round(sum(t.amount),0) as "value" from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 

    s_sqlwhere := concat(' where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.category_id is not null and plc.category_level0 not in (''Transfer'', ''Tax'', ''Bank Fees'', ''Interest'') and t.name not like ''* %'' and  t.amount > 0 and t.pending <> ''true'' and a.user_id = ', app_user_id );   

    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 
    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
  
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 

    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 

    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

    s_sqlquery_string_for_monthly_average_spending := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_monthly_average_spending, s_sqlwhere, s_groupby ,  ' order by category desc limit 5 ' , ') row' ); 

    RAISE INFO 's_sqlstring  <%>', s_sqlquery_string_for_monthly_average_spending;

    EXECUTE s_sqlquery_string_for_monthly_average_spending into graph_data_as_json;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', app_user_id;
    display_value := NULL;
    graph_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', app_user_id;
  display_value := NULL;
  graph_data_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_monthly_average_spending(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text) OWNER TO evadev;

--******************--

-- Function Name: get_yearly_average_spending
-- Purpose: Function to get yearly average spending 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_yearly_average_spending(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string_for_yearly_average_spending text := null;
  s_sqlwhere text := null;
  s_groupby text := ' group by 1 ';

BEGIN

  IF app_user_id IS NOT NULL THEN 


    s_sqlquery_string_for_yearly_average_spending := ' select to_char(date_trunc(''month'', t.transaction_date), ''YYYY'') as "category", round(sum(t.amount),0) as "value" from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 

    s_sqlwhere := concat(' where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.category_id is not null and plc.category_level0 not in (''Transfer'', ''Tax'', ''Bank Fees'', ''Interest'') and t.name not like ''* %'' and  t.amount > 0 and t.pending <> ''true'' and a.user_id = ', app_user_id );   
 

    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 
    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
  
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 

    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 

    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

    s_sqlquery_string_for_yearly_average_spending := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_yearly_average_spending, s_sqlwhere, s_groupby ,  ' order by category desc limit 5 ' , ') row' ); 

    RAISE INFO 's_sqlstring  <%>', s_sqlquery_string_for_yearly_average_spending;

    EXECUTE s_sqlquery_string_for_yearly_average_spending into graph_data_as_json;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    graph_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  graph_data_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_yearly_average_spending(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_weekly_average_spending
-- Purpose: Function to get weekly average spending 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_weekly_average_spending(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string_for_weekly_average_spending text := null;
  s_sqlwhere text := null;
  s_groupby text := ' group by 1 ';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string_for_weekly_average_spending := ' select to_char(date_trunc(''month'', t.transaction_date), ''YYYY-WW'') as "category", round(sum(t.amount),0) as "value" from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 

    s_sqlwhere := concat(' where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.category_id is not null and plc.category_level0 not in (''Transfer'', ''Tax'', ''Bank Fees'', ''Interest'') and t.name not like ''* %'' and  t.amount > 0 and t.pending <> ''true'' and a.user_id = ', app_user_id ); 

    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 
    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
  
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 

    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 

    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

    s_sqlquery_string_for_weekly_average_spending := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_weekly_average_spending, s_sqlwhere, s_groupby ,  ' order by category desc limit 4 ' , ') row' ); 

    RAISE INFO 's_sqlstring  <%>', s_sqlquery_string_for_weekly_average_spending;

    EXECUTE s_sqlquery_string_for_weekly_average_spending into graph_data_as_json;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    graph_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  graph_data_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_weekly_average_spending(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_future_financial_status
-- Purpose: Function to get future financial savings taking into consideration the current income and a 20% savings
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_future_financial_status(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string_for_future_money text := null;
  s_sqlquery_string_for_current_income text :=null;
  n_income_last_year decimal(20,2);
  s_sqlwhere text := null;
  s_groupby text := ' group by 1 ';
  n_yearly_savings decimal (20,2);
  n_savings_3 decimal (20,2);
  n_savings_6 decimal (20,2);
  n_savings_9 decimal (20,2);
  n_savings_12 decimal (20,2);
  n_savings_15 decimal (20,2);
  n_current_year integer; 
  n_year_3 integer; 
  n_year_6 integer; 
  n_year_9 integer; 
  n_year_12 integer; 
  n_year_15 integer; 

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string_for_current_income := ' select round(sum(abs(t.amount)),0) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 

    s_sqlwhere := concat(' where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.category_id is not null and t.category_id = 21009000 and a.user_id = ', app_user_id ); 

    s_sqlquery_string_for_current_income := concat(s_sqlquery_string_for_current_income, s_sqlwhere ); 

    RAISE INFO 's_sqlquery_string_for_current_income : <%>', s_sqlquery_string_for_current_income; 

    EXECUTE s_sqlquery_string_for_current_income into n_income_last_year;

    n_yearly_savings := round(n_income_last_year *.2, 0);
    n_savings_3 := round(n_yearly_savings *3, 0);
    n_savings_6 := n_savings_3 + round(n_yearly_savings *6, 0);
    n_savings_9 := n_savings_6 + round(n_yearly_savings *9, 0);
    n_savings_12 := n_savings_9 + round(n_yearly_savings *12, 0);
    n_savings_15 := n_savings_12 + round(n_yearly_savings *15, 0);
    RAISE INFO 'n_savings_15 : <%>', n_savings_15;
    select extract(year from now()) into n_current_year; 
    RAISE INFO 'n_current_year : <%>', n_current_year;
    n_year_3 := n_current_year + 3;
    n_year_6 := n_current_year + 6;
    n_year_9 := n_current_year + 9;
    n_year_12 := n_current_year + 12;
    n_year_15:= n_current_year + 15;
    RAISE INFO 'n_year_15 : <%>', n_year_15;

    graph_data_as_json := concat( '[{"category":"', n_year_3 ,'", "value":', n_savings_3, '}, {"category":"', n_year_6, '","value":', n_savings_6, '}, {"category":"', n_year_9, '", "value":', n_savings_9, '}, {"category":"', n_year_12, '","value":', n_savings_12, '}, {"category":"', n_year_15, '","value":', n_savings_15, '}]');
    RAISE INFO 'future financial graph data : <%>', graph_data_as_json;  
  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    graph_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  graph_data_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_future_financial_status(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text) OWNER TO evadev;


--******************--

--Function Name: get_next_payment_date
-- Purpose: Function to get the next payment due date 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_next_payment_date(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_previous_payment_date text := null;
  s_sqlwhere text := null;
  s_orderby text := null;

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlquery_string_for_previous_payment_date := ' select date(t.transaction_date) + 30 from  plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlwhere := concat('  where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and t.category_id = ''16001000'' and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc '; 

--------
    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    s_sqlquery_string_for_previous_payment_date := concat(s_sqlquery_string_for_previous_payment_date, s_sqlwhere, s_orderby, ' limit 1 '); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    RAISE INFO 's_sqlquery_string_for_previous_payment_date  <%>', s_sqlquery_string_for_previous_payment_date;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;
    EXECUTE s_sqlquery_string_for_previous_payment_date into display_value;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_next_payment_date(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;


--******************--

--Function Name: get_outstanding_balance
-- Purpose: Function to build the account outstanding balance query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_outstanding_balance(
    IN app_user_id integer,
    IN d_from_date text,
    IN d_to_date text,
    IN s_amount text,
    IN s_plaid_account_name text,
    IN s_plaid_account_subtype text,
    IN s_plaid_institution_id text,
    IN s_category_levels_to_check text,
    IN s_category_level0 text,
    IN s_category_level1 text,
    IN s_category_level2 text,
    IN s_ending_number text,
    IN s_txn_biz_name text,
    OUT display_value text,
    OUT account_data_as_json text)
  RETURNS record AS
$BODY$

DECLARE
  r text;
  s_sqlquery_string_for_total_outstanding text := null;
  s_sqlquery_string_for_account_json text :=null;
  s_sqlwhere text := null;
  s_orderby text := null;

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string_for_total_outstanding := ' select cast(sum(a.current_balance) as money) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i '; 

    s_sqlquery_string_for_account_json := ' SELECT i.name as "institution_name", coalesce(i.color_scheme,''4A4A4A'') as "color_scheme", i.code as "institution_id", a.name as "name", a.official_name as "official_name",a.mask as "ending_number", initcap(a.account_sub_type) as "subtype" , (cast(a.available_balance as money)) as "available_balance", (cast(a.current_balance as money)) as "current_balance", (cast(a.balance_limit as money)) as "credit_limit", round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1) as "utilization_as_value", (case when (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) <= 9 THEN ''Excellent'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 9 and 29 THEN ''Very Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 29 and 49 THEN ''Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 49 and 75 THEN ''Fair'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 75 and 100 THEN ''Very High'' ELSE ''Not Applicable'' END) as "utilizaton_band", concat(round(((a.current_balance/case a.balance_limit WHEN null THEN NULLIF(a.available_balance,0) WHEN 0 THEN NULLIF(a.available_balance,0) ELSE a.balance_limit END) *100),1) ,''%'') as "utilization_percent_as_text", a.account_id FROM plaidmanager_account a, plaidmanager_item item, plaidmanager_institutionmaster i '; 
    
    s_sqlwhere := concat(' where 1 = 1 and  lower(a.account_type) <> ''depository'' and a.account_sub_type in ( ''loan'', ''line of credit'', ''credit card'')  and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and a.user_id =   ', app_user_id );   

    s_orderby := ' order by a.name '; 


    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
  
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number, ''' ' ); 
    END IF; 

    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 

    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

    s_sqlquery_string_for_total_outstanding := concat(s_sqlquery_string_for_total_outstanding, s_sqlwhere); 
    s_sqlquery_string_for_account_json := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_account_json, s_sqlwhere, s_orderby , ') row' ); 

    RAISE INFO 's_sqlstring total outstanding: <%>', s_sqlquery_string_for_total_outstanding;
    RAISE INFO 's_sqlstring for account json <%>', s_sqlquery_string_for_account_json;

    EXECUTE s_sqlquery_string_for_total_outstanding into display_value;
    EXECUTE s_sqlquery_string_for_account_json into account_data_as_json;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', user_id;
    display_value := NULL;
    account_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', user_id;
  display_value := NULL;
  account_data_as_json := NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION get_outstanding_balance(
    IN app_user_id integer,
    IN d_from_date text,
    IN d_to_date text,
    IN s_amount text,
    IN s_plaid_account_name text,
    IN s_plaid_account_subtype text,
    IN s_plaid_institution_id text,
    IN s_category_levels_to_check text,
    IN s_category_level0 text,
    IN s_category_level1 text,
    IN s_category_level2 text,
    IN s_ending_number text,
    IN s_txn_biz_name text,
    OUT display_value text,
    OUT account_data_as_json text)
  OWNER TO evadev;

--******************--

--Function Name: get_purchasing_transactions
-- Purpose: Function to get the purchasing transactions based on user's conditions
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_purchasing_transactions(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_spend_check_value text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by plc.category_level0';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlwhere := concat(' where t.account_id = a.account_id and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %'' and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0  and t.category_id not in ( 15002000, 10000000, 10003000) and plc.category_level0 in (''Shops'', ''Food and Drink'', ''Travel'', ''Shops'', ''Recreation'', ''Services'' ) and plc.category_level1 not in (''Utilities'') and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc '; 

--------

    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 

    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_category_levels_to_check IS NOT NULL) THEN 
      IF s_category_levels_to_check = '0' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level0) =''', lower(s_category_level0), ''' '); 
      ELSIF s_category_levels_to_check = '1' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level1) =''', lower(s_category_level1), ''' '); 
      ELSIF s_category_levels_to_check = '2' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level2) =''', lower(s_category_level2), ''' '); 
    END IF; 

    END IF; 
    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 
    END IF; 

    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 
    IF (s_plaid_account_subtype IS NOT NULL) THEN
      s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;

  ELSE 
    RAISE INFO 'Inside else where user id is not null : <%>', app_user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  RAISE INFO 'Inside exception : <%>', app_user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_purchasing_transactions(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_recurring_charges
-- Purpose: Function to get the recurring charges for the user
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_recurring_charges(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlwhere text := null;
  s_subjoin text := null;
  s_orderby text := null;
BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc ';

    s_sqlwhere := concat(' where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and plc.category_level0 not in (''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'') and a.user_id = ', app_user_id );   
    s_subjoin := concat (' and t.name in (select t.name from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and t.user_id = ', app_user_id, '  and plc.category_level0 not in (''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'') group by t.name having count(*) >1) ', null); 
    s_orderby := ' order by t.transaction_date desc  '; 
    --RAISE INFO 's_sqlquery_string at begin <%>', s_sqlquery_string;

--------
    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 

    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 

    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' ');
    END IF; 

    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number, ''' ' ); 
    END IF; 
    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_subjoin, s_orderby , ') row' ); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;

  ELSE 
    RAISE INFO 'Inside else where user id is not null : <%>', app_user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  RAISE INFO 'Inside exception : <%>', app_user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_recurring_charges(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_spend_by_category
-- Purpose: Machine Learning model to build the spending by category
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_spend_by_category(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string_for_spend_by_category text := null;
  s_sqlwhere text := null;
  s_groupby text := ' group by plc.category_level0';
  s_sqlquery_for_display_notes text; 
  s_sqlquery_string_for_spend_by_category_notes text; 

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string_for_spend_by_category := ' select round(sum(t.amount)) as "value", (case when (plc.category_level0) = ''Transfer'' THEN '':arrow_right:'' WHEN (plc.category_level0) = ''Payment'' THEN '':money_with_wings:'' WHEN (plc.category_level0) = ''Food and Drink'' THEN '':fork_and_knife:'' WHEN (plc.category_level0) = ''Community'' THEN '':house_with_garden:'' WHEN (plc.category_level0) = ''Bank Fees'' THEN '':bank:'' WHEN (plc.category_level0) = ''Healthcare'' THEN '':hospital:'' WHEN (plc.category_level0) = ''Travel'' THEN '':airplane:'' WHEN (plc.category_level0) = ''Cash Advance'' THEN '':moneybag:'' WHEN (plc.category_level0) = ''Tax'' THEN '':dollar:'' WHEN (plc.category_level0) = ''Shops'' THEN '':gift:'' WHEN (plc.category_level0) = ''Recreation'' THEN '':roller_coaster:'' WHEN (plc.category_level0) = ''Service'' THEN '':convenience_store:'' WHEN (plc.category_level0) = ''Interest'' THEN '':credit_card:'' ELSE plc.category_level0 END) as "category" from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 

    s_sqlquery_string_for_spend_by_category_notes :=' select round(sum(t.amount)) as "value", plc.category_level0 as "category"  from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 

    s_sqlwhere := concat(' where t.account_id = a.account_id and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and  plc.category_level0 not in (''Service'', ''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'') and  t.amount > 0 and a.user_id = ', app_user_id );

    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 
    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
  
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 

    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 

    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

    s_sqlquery_for_display_notes := concat('select string_agg(distinct category::text,''     '') from (select distinct (case when (category) = ''Transfer'' THEN '':arrow_right: - Transfer '' WHEN (category) = ''Payment'' THEN '':money_with_wings: - Payment '' WHEN (category) = ''Food and Drink'' THEN '':fork_and_knife: - Food and Drink '' WHEN (category) = ''Community'' THEN '':house_with_garden: - Community '' WHEN (category) = ''Bank Fees'' THEN '':bank: - Bank Fees '' WHEN (category) = ''Healthcare'' THEN '':hospital: - Healthcare '' WHEN (category) = ''Travel'' THEN '':airplane: - Travel '' WHEN (category) = ''Cash Advance'' THEN '':moneybag: - Cash Advance '' WHEN (category) = ''Tax'' THEN '':dollar: - Tax '' WHEN (category) = ''Shops'' THEN '':gift: - Shops '' WHEN (category) = ''Recreation'' THEN '':roller_coaster: - Recreation '' WHEN (category) = ''Service'' THEN '':convenience_store: - Service '' WHEN (category) = ''Interest'' THEN '':credit_card: - Interest '' ELSE category END) from ( ', s_sqlquery_string_for_spend_by_category_notes, s_sqlwhere, s_groupby , '  order by value desc limit 5 ) a ) b'); 

    s_sqlquery_string_for_spend_by_category := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_spend_by_category, s_sqlwhere, s_groupby ,  ' order by value desc limit 5 ' , ') row' ); 

    RAISE INFO 's_sqlstring  <%>', s_sqlquery_string_for_spend_by_category;

    RAISE INFO 's_sqlquery_for_display_notes  <%>', s_sqlquery_for_display_notes;

    EXECUTE s_sqlquery_string_for_spend_by_category into graph_data_as_json; 

    EXECUTE s_sqlquery_for_display_notes into display_value; 

  ELSE 
    RAISE INFO 'Inside else where user id is not null : <%>', app_user_id;
    display_value := NULL;
    graph_data_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  RAISE INFO 'Inside exception : <%>', app_user_id;
  display_value := NULL;
  graph_data_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_spend_by_category(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT graph_data_as_json text) OWNER TO evadev;



--******************--

--Function Name: get_spend_check
-- Purpose: Function to build the spending by categort
-- version: 0.0 - baseline version


CREATE OR REPLACE FUNCTION get_spend_check(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_spend_check_value text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by plc.category_level0';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlquery_string_for_spend_check_value := ' select cast(sum(t.amount) as money) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  ';

    s_sqlwhere := concat('  where t.account_id = a.account_id and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %'' and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and plc.category_level0 not in ( ''Bank Fees'', ''Interest'', ''Tax'') and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc '; 
--removed ''Transfer'', ''Payment'' from the condition
--------
    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 

    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_category_levels_to_check IS NOT NULL) THEN 
      IF s_category_levels_to_check = '0' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level0) =''', lower(s_category_level0), ''' '); 
      ELSIF s_category_levels_to_check = '1' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level1) =''', lower(s_category_level1), ''' '); 
      ELSIF s_category_levels_to_check = '2' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level2) =''', lower(s_category_level2), ''' '); 
    END IF; 

    END IF; 
    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 
    END IF; 

    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    s_sqlquery_string_for_spend_check_value := concat(s_sqlquery_string_for_spend_check_value, s_sqlwhere ); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    RAISE INFO 's_sqlquery_string_for_spend_check_value  <%>', s_sqlquery_string_for_spend_check_value;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;
    EXECUTE s_sqlquery_string_for_spend_check_value into display_value;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', app_user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  RAISE INFO 'Inside exception : <%>', app_user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$ LANGUAGE plpgsql;

ALTER FUNCTION get_spend_check(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_atm_withdrawals
-- Purpose: Function to get atm withdrawal information 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_atm_withdrawals(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_atm_withdrawals text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by plc.category_level0';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlquery_string_for_atm_withdrawals := ' select cast(sum(t.amount) as money) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 
    s_sqlwhere := concat('  where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and t.category_id = 21012000 and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc '; 

--------
    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 

    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_category_levels_to_check IS NOT NULL) THEN 
      IF s_category_levels_to_check = '0' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level0) =''', lower(s_category_level0), ''' '); 
      ELSIF s_category_levels_to_check = '1' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level1) =''', lower(s_category_level1), ''' '); 
      ELSIF s_category_levels_to_check = '2' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level2) =''', lower(s_category_level2), ''' '); 
    END IF; 

    END IF; 
    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 

    END IF; 

    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    s_sqlquery_string_for_atm_withdrawals := concat(s_sqlquery_string_for_atm_withdrawals, s_sqlwhere ); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    RAISE INFO 's_sqlquery_string_for_atm_withdrawals  <%>', s_sqlquery_string_for_atm_withdrawals;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;
    EXECUTE s_sqlquery_string_for_atm_withdrawals into display_value;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', app_user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', app_user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_atm_withdrawals(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_user_earnings
-- Purpose: Function to get user earning information 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_user_earnings(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_user_earning text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by plc.category_level0';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlquery_string_for_user_earning := ' select cast(sum(abs(t.amount)) as money) from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlwhere := concat(' where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and t.category_id in (21007000, 21009000, 21011000, 20001000) and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc '; 

--------
    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 

    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_category_levels_to_check IS NOT NULL) THEN 
      IF s_category_levels_to_check = '0' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level0) =''', lower(s_category_level0), ''' '); 
      ELSIF s_category_levels_to_check = '1' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level1) =''', lower(s_category_level1), ''' '); 
      ELSIF s_category_levels_to_check = '2' THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and lower(plc.category_level2) =''', lower(s_category_level2), ''' '); 
    END IF; 

    END IF; 
    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 
    END IF; 

    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number , ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    s_sqlquery_string_for_user_earning := concat(s_sqlquery_string_for_user_earning, s_sqlwhere ); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    RAISE INFO 's_sqlquery_string_for_user_earning  <%>', s_sqlquery_string_for_user_earning;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;
    EXECUTE s_sqlquery_string_for_user_earning into display_value;

  ELSE 
    RAISE INFO 'Inside else where user id is not null : <%>', app_user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  RAISE INFO 'Inside exception : <%>', app_user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_user_earnings(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--
-- Function Name: get_subscription_charges
-- Purpose: Function to get subscription charges based on users query and conditions
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_subscription_charges(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_string text := null;
  s_sqlquery_string_for_spend_check_value text := null;
  s_sqlwhere text := null;
  s_orderby text := null;
  s_groupby text := ' group by plc.category_level0';

BEGIN

  IF app_user_id IS NOT NULL THEN 

    s_sqlquery_string := ' select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", a.mask,  initcap(a.account_sub_type) as "account_type", (case when date(t.transaction_date) = date(now()) THEN ''Today'' WHEN date(t.transaction_date) = date(now())-1 THEN ''Yesterday'' ELSE concat(substr(rtrim(initcap(to_char(t.transaction_date, ''day''))),1, 3),'', '', substr(rtrim(to_char(t.transaction_date, ''Month'')),1,3), '' '', date_part(''day'', t.transaction_date), '', '', EXTRACT(YEAR FROM t.transaction_date)) END ) as "transaction_date_as_display", abs(t.amount) as "amount", cast(abs(t.amount) as money) as "display_amount", initcap(t.name) as "name", plc.category_level0 as "category0" , plc.category_level1 as "category1" , plc.category_level2  as "category2" , t.pending from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc '; 
    s_sqlquery_string_for_spend_check_value := ' select cast(sum(t.amount) as money)  from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  '; 
    s_sqlwhere := concat('  where t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.name not like ''* %''  and t.pending <> ''true'' and t.category_id is not null and t.category_id <>0 and lower(plc.category_level1) in (''subscription'', ''cable'', ''insurance'') and a.user_id = ', app_user_id );   
    s_orderby := ' order by t.transaction_date desc '; 

--------
    IF ((d_from_date IS NOT NULL) and (d_to_date IS NOT NULL)) THEN 
        s_sqlwhere := concat(s_sqlwhere, ' and t.transaction_date >= ''', d_from_date, ''' and t.transaction_date <= ''', d_to_date ,''''); 
        --RAISE INFO 'Inside date IF : <%>', s_sqlwhere; 
    END IF; 
    IF (s_plaid_account_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.name) = ''', lower(s_plaid_account_name), ''' '); 
    END IF; 
    IF (s_txn_biz_name IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(t.name) like ''%', lower(s_txn_biz_name), '%'' '); 
    END IF; 
    IF (s_ending_number IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and a.mask = ''', s_ending_number, ''' ' ); 
    END IF; 
    IF (s_plaid_account_subtype IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(a.account_sub_type) = ''', lower(s_plaid_account_subtype), ''' '); 
    END IF; 
    IF (s_plaid_institution_id IS NOT NULL) THEN
        s_sqlwhere := concat(s_sqlwhere, ' and lower(i.code) = ''', lower(s_plaid_institution_id), ''' '); 
    END IF; 

----------
    s_sqlquery_string := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string, s_sqlwhere, s_orderby , ') row' ); 
    s_sqlquery_string_for_spend_check_value := concat(s_sqlquery_string_for_spend_check_value, s_sqlwhere ); 

    RAISE INFO 's_sqlquery_string  <%>', s_sqlquery_string;
    
    EXECUTE s_sqlquery_string into transaction_output_as_json;

  ELSE 
    --RAISE INFO 'Inside else where user id is not null : <%>', app_user_id;
    display_value := NULL;
    transaction_output_as_json := NULL;
  END IF; 

EXCEPTION WHEN OTHERS THEN
  --RAISE INFO 'Inside exception : <%>', app_user_id;
  display_value := NULL;
  transaction_output_as_json := NULL;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_subscription_charges(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT transaction_output_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_user_net_worth
-- Purpose: Function to get the user net worth
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_user_net_worth(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text)
AS $$

DECLARE
  s_available_balance_types text := '(''depository'')'; 
  s_available_balance_sqlstring text := 'select sum(coalesce(available_balance,0)) from plaidmanager_account where account_type in '; 
  s_net_worth_string text; 
  s_outstanding_balance_types text := '(''credit'', ''loan'')'; 
  s_outstanding_balance_sqlstring text := 'select sum(coalesce(current_balance,0)) from plaidmanager_account where account_type in '; 
  s_sqlquery_string_for_account_json text :=null;
  s_sqlwhere text := null;
  s_orderby text := null;

BEGIN
  IF (app_user_id IS NOT NULL) THEN 
    BEGIN 
      s_net_worth_string := concat('select cast(( ', s_available_balance_sqlstring, s_available_balance_types, ' and user_id = ', app_user_id, ' ) - (', s_outstanding_balance_sqlstring, s_outstanding_balance_types, ' and deleted_at is null and  user_id = ', app_user_id, ') as money)'); 
      RAISE INFO 's_net_worth_string <%>', s_net_worth_string;

      EXECUTE s_net_worth_string into display_value; 
    EXCEPTION WHEN OTHERS THEN   
      display_value := NULL;
    END; 
    s_sqlquery_string_for_account_json := ' SELECT i.name as "institution_name", coalesce(i.color_scheme,''4A4A4A'') as "color_scheme", i.code as "institution_id", a.name as "name", a.official_name as "official_name",a.mask as "ending_number", initcap(a.account_sub_type) as "subtype" , (cast(a.available_balance as money)) as "available_balance", (cast(a.current_balance as money)) as "current_balance", (cast(a.balance_limit as money)) as "credit_limit", round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1) as "utilization_as_value", (case when (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) <= 9 THEN ''Excellent'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 9 and 29 THEN ''Very Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 29 and 49 THEN ''Good'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 49 and 75 THEN ''Fair'' WHEN (round(((a.current_balance/case a.balance_limit WHEN null THEN NULL WHEN 0 THEN NULL ELSE a.balance_limit END) *100),1)) between 75 and 100 THEN ''Very High'' ELSE ''Not Applicable'' END) as "utilizaton_band", concat(round(((a.current_balance/case a.balance_limit WHEN null THEN NULLIF(a.available_balance,0) WHEN 0 THEN NULLIF(a.available_balance,0) ELSE a.balance_limit END) *100),1) ,''%'') as "utilization_percent_as_text", a.account_id FROM plaidmanager_account a, plaidmanager_item item, plaidmanager_institutionmaster i '; 
    
    s_sqlwhere := concat(' where 1 = 1 and a.plaidmanager_item_id = item.id and item.institute_id = i.id and lower(a.account_type) in (''depository'', ''credit'', ''loan'') and a.deleted_at is null and a.user_id =   ', app_user_id );

    s_orderby := ' order by a.name ';
    s_sqlquery_string_for_account_json := concat('select json_agg(row_to_json(row)) from (', s_sqlquery_string_for_account_json, s_sqlwhere, s_orderby , ') row' ); 
    RAISE INFO 's_sqlstring for account json <%>', s_sqlquery_string_for_account_json;
    EXECUTE s_sqlquery_string_for_account_json into account_data_as_json;
  ELSE 
    RAISE INFO 'Inside else where user id is not null : <%>', app_user_id;
    display_value := NULL;
    account_data_as_json := NULL;
  END IF; 
EXCEPTION WHEN OTHERS THEN
  display_value := NULL; 
  account_data_as_json := NULL; 
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_user_net_worth(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text) OWNER TO evadev;  

--******************--

--Function Name: get_can_i_spend_results
-- Purpose: Function to get the results if the user can spend the money 
-- version: 0.0 - baseline version
-- 

CREATE OR REPLACE FUNCTION get_can_i_spend_results(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text)
AS $$

DECLARE
  r text;
  s_sqlquery_utilization text := null;
  s_sqlquery_string_for_account_json text :=null;
  s_sqlwhere text := null;
  s_orderby text := null;
  n_amount numeric :=0; -- to convert s_amount into numeric
  b_user_amount boolean := TRUE; 

BEGIN
 /* 
 Need to complete this function
*/  
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_can_i_spend_results(app_user_id IN integer, d_from_date IN text, d_to_date IN text, s_amount IN text, s_plaid_account_name IN text, s_plaid_account_subtype IN text, s_plaid_institution_id IN text, s_category_levels_to_check IN text, s_category_level0 IN text, s_category_level1 IN text, s_category_level2 IN text, s_ending_number IN text, s_txn_biz_name IN text, OUT display_value text, OUT account_data_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_user_insights
-- Purpose: Function to get user insights to display in the insights page 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_user_insights(app_user_id IN integer, OUT snapshot_output_as_json text, OUT forecast_data_as_json text, OUT transactions_data_as_json text, OUT spend_by_category_data_as_json text, OUT utilization_data_as_json text, OUT improve_credit_data_as_json text, OUT card_recommendation_data_as_json text, OUT subscriptions_data_as_json text, OUT interest_paid_data_as_json text)
AS $$

DECLARE
  --snapshot
  s_sqlquery_total_cash text := ' select cast(sum(a.available_balance) as money) from plaidmanager_account a where a.account_sub_type = ''checking'' and a.deleted_at is null and ';
  s_sqlquery_snapshot_where text := ' user_id = ';
  s_sqlquery_total_available_credit text :=' select cast(sum(a.available_balance) as money) from plaidmanager_account a where a.account_sub_type = ''credit card'' and a.deleted_at is null and '; 
  s_sqlquery_total_outstanding_balance text := ' select cast(sum(a.current_balance) as money) from plaidmanager_account a where a.account_sub_type = ''credit card'' and a.deleted_at is null and '; 
 
  --forecast
  s_latest_user_transaction_date text;
  n_txn_sum_last_30_days numeric(20,2); 
  n_txn_sum_last_90_days numeric(20,2); 

  n_txn_sum_today numeric(20,2); 
  n_txn_sum_this_month numeric(20,2); 

  n_average_daily_spend numeric(20,2);
  n_average_monthly_spend numeric(20,2);
  n_todays_forecast numeric(20,2);
  n_this_month_forecast numeric(20,2);

  s_sqlquery_latest_transaction_date text :=' select t.transaction_date from plaidmanager_transaction t, plaidmanager_account a , plaidmanager_categorymaster plc  where t.account_id = a.account_id and t.category_id = plc.plaid_category_id and t.category_id is not null and t.category_id <>0 and plc.category_level0 not in (''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'') and a.deleted_at is null and  t.deleted_at is null and  t.amount > 0 and a.user_id = '; 

  s_sqlquery_sum_from_transactions_minus_30days text :=' select sum(t.amount) from plaidmanager_transaction t, plaidmanager_account a , plaidmanager_categorymaster plc where t.account_id = a.account_id and t.category_id = plc.plaid_category_id and t.category_id is not null and t.category_id <>0 and plc.category_level0 not in (''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'') and a.deleted_at is null and t.deleted_at is null and  t.amount > 0 and a.user_id = '  ; 
  s_sqlwhere_sum_from_transactions_minus_30days text := ' and t.transaction_date >= '  ;

  s_sqlquery_sum_from_transactions_minus_90days text :=' select sum(t.amount) from plaidmanager_transaction t, plaidmanager_account a , plaidmanager_categorymaster plc where t.account_id = a.account_id and t.category_id = plc.plaid_category_id and t.category_id is not null and t.category_id <>0 and plc.category_level0 not in (''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'') and a.deleted_at is null and t.deleted_at is null and t.amount > 0 and a.user_id = '  ; 
  s_sqlwhere_sum_from_transactions_minus_90days text := ' and t.transaction_date >= '  ;

  s_sqlquery_sum_from_transactions_today text :=' select sum(t.amount) from plaidmanager_transaction t, plaidmanager_account a , plaidmanager_categorymaster plc where t.account_id = a.account_id and t.category_id = plc.plaid_category_id and t.category_id is not null and t.category_id <>0 and plc.category_level0 not in (''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'') and a.deleted_at is null and t.deleted_at is null and  t.amount > 0 and a.user_id = '  ; 
  s_sqlwhere_sum_from_transactions_today text := ' and t.transaction_date = '  ;
  
  s_sqlquery_sum_from_transactions_this_month text :=' select sum(t.amount) from plaidmanager_transaction t, plaidmanager_account a , plaidmanager_categorymaster plc where t.account_id = a.account_id and t.category_id = plc.plaid_category_id and t.category_id is not null and t.category_id <>0 and plc.category_level0 not in (''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'') and a.deleted_at is null and  t.deleted_at is null and  t.amount > 0 and a.user_id = '  ; 
  s_sqlwhere_sum_from_transactions_this_month text := ' and t.transaction_date '  ;

  s_daily_forecast_image text ;
  s_daily_forecast_message text;

  s_monthly_forecast_image text ;
  s_monthly_forecast_message text;

  
  s_sqlwhere text := null ;
  s_orderby_latest_transaction_date text := ' order by t.transaction_date desc limit 1 ';

  -- transactions
  s_sqlquery_recent_transactions text := 'select json_agg(row_to_json(row)) from (select i.name as "institution_name", i.code as "institution_id", t.account_id, a.name as "account_name", t.transaction_id, upper(t.name) as "name", t.amount, cast(t.amount as money) as "display_amount" from  plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc  where t.account_id = a.account_id and a.plaidmanager_item_id = item.id and item.institute_id = i.id and t.category_id = plc.plaid_category_id and a.deleted_at is null and t.deleted_at is null and t.category_id is not null and t.category_id <>0  and t.category_id not in ( 15002000, 10000000, 10003000) and plc.category_level0 in (''Shops'', ''Food and Drink'', ''Travel'', ''Recreation'', ''Service'' , ''Transfer'') and  plc.category_level1 not in (''Utilities'')  and a.user_id = '; 

  s_sqlquery_recent_transactions_orderby text := ' order by t.transaction_date desc limit 5 '; 
  
  --spend by category
  s_sqlquery_spend_by_category text :='select json_agg(row_to_json(row)) from (select round(sum(t.amount)) as "value", (case when (plc.category_level0) = ''Transfer'' THEN '':arrow_right:'' WHEN (plc.category_level0) = ''Payment'' THEN '':money_with_wings:'' WHEN (plc.category_level0) = ''Food and Drink'' THEN '':fork_and_knife:'' WHEN (plc.category_level0) = ''Community'' THEN '':house_with_garden:'' WHEN (plc.category_level0) = ''Bank Fees'' THEN '':bank:'' WHEN (plc.category_level0) = ''Healthcare'' THEN '':hospital:'' WHEN (plc.category_level0) = ''Travel'' THEN '':airplane:'' WHEN (plc.category_level0) = ''Cash Advance'' THEN '':moneybag:'' WHEN (plc.category_level0) = ''Tax'' THEN '':dollar:'' WHEN (plc.category_level0) = ''Shops'' THEN '':gift:'' WHEN (plc.category_level0) = ''Recreation'' THEN '':roller_coaster:'' WHEN (plc.category_level0) = ''Service'' THEN '':convenience_store:'' WHEN (plc.category_level0) = ''Interest'' THEN '':credit_card:'' ELSE plc.category_level0 END) as "category" , plc.category_level0 as "category_name" from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc where  t.account_id = a.account_id and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.deleted_at is null and t.category_id is not null and t.category_id <>0 and plc.category_level0 not in (''Transfer'', ''Payment'', ''Bank Fees'', ''Interest'', '''') and t.transaction_date >= date(now())-30 and t.amount > 0 and a.user_id = '; 
  s_sqlquery_spend_by_category_orderby text := ' group by plc.category_level0 order by value desc limit 5 '; 

  --subscriptions
  s_sqlquery_subscriptions text :='select json_agg(row_to_json(row)) from (select i.code as "institution_id", i.name as "institution_name", initcap(a.name) as "account_name", upper(t.name) as "name" from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc where  t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.deleted_at is null and t.category_id is not null and t.category_id <>0 and lower(plc.category_level1) in (''subscription'', ''cable'', ''insurance'') and  t.transaction_date >= date(now())-30 and a.user_id = '; 

  s_sqlquery_subscriptions_orderby text := ' group by i.code, i.name, a.name, t.name order by t.name asc '; 

  -- utilization 
  s_sqlquery_utilization text := 'select json_agg(row_to_json(row)) from (select round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1) as "value", concat(round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%'') as "value_with_percentage", (case when round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1) <= 9 THEN concat (''Your overall credit usage is '', round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%. Wow, looks like you are in complete control, great job in managing your credit wisely!'') WHEN round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1) between 9 and 29 THEN concat (''Your overall credit usage is '', round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%. Awesome job in maintaining a low usage, but there is still room for improvement.'') WHEN round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1) between 29 and 49 THEN concat (''Your overall credit usage is '', round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%. Good job in using less than half your available credit but there is still room for improvement!'') WHEN round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1) between 49 and 75 THEN concat (''Your overall credit usage is '', round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%. Your usage is high, so please payoff a partial value and get the credit usage down.'') WHEN round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1) between 75 and 100 THEN concat (''Your overall credit usage is '', round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%. Heads up for the high usage level, time to tighten up your spending and get back into control. Please payoff a partial value and get the credit usage down.'') ELSE ''Not Applicable'' END) as "text" from plaidmanager_account a where 1 = 1 and a.balance_limit is not null and a.balance_limit <>0 and lower(a.account_sub_type) = ''credit card''  and a.deleted_at is null and a.user_id = ';

  s_sqlquery_interest_paid text := 'select json_agg(row_to_json(row)) from (select cast(coalesce(sum(t.amount),0) as money) as "value", concat(''You have paid '', cast(coalesce(sum(t.amount),0) as money) ,'' as interest and late payment fees in the past 30 days'' ) as "text" from  plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i , plaidmanager_transaction t , plaidmanager_categorymaster plc where t.transaction_date >= date(now())-30 and  t.account_id = a.account_id and  a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and t.category_id = plc.plaid_category_id and t.deleted_at is null and t.category_id is not null and t.category_id <>0 and t.category_id in ( 15002000, 10000000, 10003000) and a.user_id = ';

  -- improve credit score
  s_sqlquery_improve_credit text := 'select * from get_improve_credit_score (';
  s_improve_credit_where text := ', null, null, null, null, null, null, null, null, null, null, null, null) ';

  --storage variables
  s_total_cash text; 
  s_total_available_credit text; 
  s_total_outstanding_balance text; 
  todays_forecast_image text;
  monthly_forecast_image text;
  s_display_message text;
  s_display_notes text;
  s_voice_message text; 
  s_account_data_as_json text;
  n_query_tear_down_id integer;
  s_user_query_text text;
  s_amount_for_card_reco text;
  s_this_month_start_date text;
  s_this_month_end_date text;
  s_matched_date_keyword_insights text;

BEGIN

--snapshot

  s_sqlquery_total_cash := concat(s_sqlquery_total_cash, s_sqlquery_snapshot_where, app_user_id); 
  BEGIN
    EXECUTE s_sqlquery_total_cash into s_total_cash; 
    IF s_total_cash IS NULL THEN 
      s_total_cash :='Unavailable';
    END IF; 

  EXCEPTION WHEN OTHERS THEN
      s_total_cash :='Unavailable';
  END;

  s_sqlquery_total_available_credit := concat(s_sqlquery_total_available_credit, s_sqlquery_snapshot_where, app_user_id); 

  BEGIN
    EXECUTE s_sqlquery_total_available_credit into s_total_available_credit; 
    IF s_total_available_credit IS NULL THEN 
      s_total_available_credit :='Unavailable';
    END IF;

  EXCEPTION WHEN OTHERS THEN
    s_total_available_credit :='Unavailable';  
  END;

  s_sqlquery_total_outstanding_balance := concat(s_sqlquery_total_outstanding_balance, s_sqlquery_snapshot_where, app_user_id); 

  BEGIN
    EXECUTE s_sqlquery_total_outstanding_balance into s_total_outstanding_balance; 
    IF s_total_outstanding_balance IS NULL THEN 
      s_total_outstanding_balance :='Unavailable';
    END IF;
    
  EXCEPTION WHEN OTHERS THEN
    s_total_outstanding_balance :='Unavailable';  
  END;

  snapshot_output_as_json := concat('"snapshot": [{"total_cash": "', s_total_cash, '","total_outstanding_balance": "', s_total_outstanding_balance, '","total_available_credit": "', s_total_available_credit, '"}]'); 
  --RAISE INFO 'snapshot_output_as_json inside the function: <%>', snapshot_output_as_json;

--forecast
  BEGIN
    s_sqlquery_latest_transaction_date := concat(s_sqlquery_latest_transaction_date, app_user_id, s_orderby_latest_transaction_date );
    RAISE INFO 's_sqlquery_latest_transaction_date sql: <%>', s_sqlquery_latest_transaction_date;
    EXECUTE s_sqlquery_latest_transaction_date into s_latest_user_transaction_date; 
    IF s_latest_user_transaction_date is null THEN 
      s_latest_user_transaction_date :=date(now());
    END IF;
    RAISE INFO 's_latest_user_transaction_date sql: <%>', s_latest_user_transaction_date;

  EXCEPTION WHEN OTHERS THEN 
    s_latest_user_transaction_date :=date(now());
  END; 

  -- /* code for daily forecast*/
  -- get total spent 30 days from the last transaction date
  BEGIN
    s_sqlquery_sum_from_transactions_minus_30days := concat( s_sqlquery_sum_from_transactions_minus_30days, app_user_id, s_sqlwhere_sum_from_transactions_minus_30days, ' date( ''' , s_latest_user_transaction_date, ''') - 30 ' );

    RAISE INFO 's_sqlquery_sum_from_transactions_minus_30days sql: <%>', s_sqlquery_sum_from_transactions_minus_30days;
    EXECUTE s_sqlquery_sum_from_transactions_minus_30days into n_txn_sum_last_30_days; 
    RAISE INFO 'n_txn_sum_last_30_days sql: <%>', n_txn_sum_last_30_days;
    IF n_txn_sum_last_30_days is null THEN 
      n_txn_sum_last_30_days := -1;
    END IF;
    n_average_daily_spend := round((n_txn_sum_last_30_days/30), 0); 
    RAISE INFO 'n_average_daily_spend sql: <%>', n_average_daily_spend;
  EXCEPTION WHEN OTHERS THEN 
      n_txn_sum_last_30_days := -1;
  END;
  -- get total spent today
  BEGIN
    s_sqlquery_sum_from_transactions_today := concat( s_sqlquery_sum_from_transactions_today, app_user_id, s_sqlwhere_sum_from_transactions_today, '''' , date(now()), ''' ' );
    RAISE INFO 's_sqlquery_sum_from_transactions_today sql: <%>', s_sqlquery_sum_from_transactions_today;
    EXECUTE s_sqlquery_sum_from_transactions_today into n_txn_sum_today;
    RAISE INFO 'n_txn_sum_today sql: <%>', n_txn_sum_today;
    IF n_txn_sum_today is null THEN 
      n_txn_sum_today := 0;
    END IF;
  EXCEPTION WHEN OTHERS THEN 
      n_txn_sum_today := 0;
  END;

  n_todays_forecast := round(((n_txn_sum_today / n_average_daily_spend)*100), 0);
  RAISE INFO 'n_todays_forecast sql: <%>', n_todays_forecast;
  IF n_todays_forecast <=50 THEN 
    s_daily_forecast_image :='sunny';
    s_daily_forecast_message := concat('Sunny day for your money! You have spent <b>', cast(n_txn_sum_today as money), '</b> today, much less than your average daily spend of <b>', cast(n_average_daily_spend as money), '</b>. Great job :thumbsup:!');
  ELSIF (n_todays_forecast >50 and n_todays_forecast <=100) THEN
    s_daily_forecast_image :='cloudy';
    s_daily_forecast_message := concat('Cloudy day for your money! You have so far spent <b>', cast(n_txn_sum_today as money), '</b> today, and fast approaching your average daily spend of <b>', cast(n_average_daily_spend as money), '</b>. Good job, and try to stay within your spending limits :wink:');

  ELSIF (n_todays_forecast >100) THEN
    s_daily_forecast_image :='rainy';
    s_daily_forecast_message := concat('<p><font face=''HelveticaNeue'' size=''4'' color=''gray''>Rainy day for your money! You have so far spent <font size=''3'' color=''black''><b>', cast(n_txn_sum_today as money), '</b></font> today, more than your average daily spend of <font size=''3'' color=''black''>', cast(n_average_daily_spend as money), '<b><font>. Stay focussed and try to curb your spending enthusiasm :slight_smile:!');

  ELSE 
    s_daily_forecast_image :='unknown';
    s_daily_forecast_message := concat('Sorry, I was unable to get your forecast information right now :worried: , please check back again soon!');

  END IF;
  --RAISE INFO 's_daily_forecast_image sql: <%>', s_daily_forecast_image;
  --RAISE INFO 's_daily_forecast_message sql: <%>', s_daily_forecast_message;

  /* code end for daily forecasts */

  /* code begins for monthly forecast*/

  BEGIN
    s_sqlquery_sum_from_transactions_minus_90days := concat( s_sqlquery_sum_from_transactions_minus_90days, app_user_id, s_sqlwhere_sum_from_transactions_minus_90days, ' date( ''' , s_latest_user_transaction_date, ''') - 90 ' );
    EXECUTE s_sqlquery_sum_from_transactions_minus_90days into n_txn_sum_last_90_days; 
    IF n_txn_sum_last_90_days is null THEN 
      n_txn_sum_last_90_days := -1;
    END IF;
    n_average_monthly_spend := round((n_txn_sum_last_90_days/3), 0); 
    --RAISE INFO 'n_average_monthly_spend sql: <%>', n_average_monthly_spend;
  EXCEPTION WHEN OTHERS THEN 
      n_average_monthly_spend := -1;
  END;
  -- get total spent this month
  BEGIN
    SELECT * from get_date_from_user_query('get the dates for this month please') INTO s_this_month_start_date, s_this_month_end_date, s_matched_date_keyword_insights;
    IF s_this_month_start_date is NULL THEN 
      s_this_month_start_date := cast(date_trunc('month', now()) as date);
    END IF; 
    IF s_this_month_end_date is NULL THEN 
      s_this_month_end_date := CURRENT_DATE;
    END IF; 

  EXCEPTION WHEN OTHERS THEN
    s_this_month_start_date := cast(date_trunc('month', now()) as date);
    s_this_month_end_date := CURRENT_DATE;
  END;
  BEGIN
    s_sqlquery_sum_from_transactions_this_month := concat( s_sqlquery_sum_from_transactions_this_month, app_user_id, s_sqlwhere_sum_from_transactions_this_month, ' >= ''' , s_this_month_start_date , '''  ' , s_sqlwhere_sum_from_transactions_this_month, ' <= ''' , s_this_month_end_date, '''' );
    RAISE INFO 's_sqlquery_sum_from_transactions_this_month sql: <%>', s_sqlquery_sum_from_transactions_this_month;
    EXECUTE s_sqlquery_sum_from_transactions_this_month into n_txn_sum_this_month;
    --RAISE INFO 'n_txn_sum_this_month sql: <%>', n_txn_sum_this_month;
    IF n_txn_sum_this_month is null THEN 
      n_txn_sum_this_month := 0;
    END IF;
  EXCEPTION WHEN OTHERS THEN 
      n_txn_sum_this_month := 0;
  END;

  n_this_month_forecast := round(((n_txn_sum_this_month / n_average_monthly_spend)*100), 0);
  --RAISE INFO 'n_this_month_forecast sql: <%>', n_this_month_forecast;
  IF n_this_month_forecast <=50 THEN 
    s_monthly_forecast_image :='sunny';
    s_monthly_forecast_message := concat('Sunny forecast for your money so far! You have spent <b>', cast(n_txn_sum_this_month as money), '</b> this month, much less than your average monthly spend of <b>', cast(n_average_monthly_spend as money), '</b>. Great job :thumbsup:!');
  ELSIF (n_this_month_forecast >50 and n_this_month_forecast <=100) THEN
    s_monthly_forecast_image :='cloudy';
    s_monthly_forecast_message := concat('Warm conditions for your money! You have so far spent <b>', cast(n_txn_sum_this_month as money), '</b> this month, and fast approaching your average monthly spend of <b>', cast(n_average_monthly_spend as money), '</b>. Good job, and try to stay within your spending limits :wink:');
  ELSIF (n_this_month_forecast >100) THEN
    s_monthly_forecast_image :='rainy';
    s_monthly_forecast_message := concat('Looks like rainy days! You have so far spent <b>', cast(n_txn_sum_this_month as money), '</b> this month, more than your average monthly spend of <b>', cast(n_average_monthly_spend as money), '</b>. Stay focussed and try to curb your spending enthusiasm :slight_smile:!');

  ELSE 
    s_monthly_forecast_image :='unknown';
    s_monthly_forecast_message := concat('Sorry, I was unable to get your forecast information right now :worried: , please check back again soon!');

  END IF;
  --RAISE INFO 's_monthly_forecast_image sql: <%>', s_monthly_forecast_image;
  --RAISE INFO 's_monthly_forecast_message sql: <%>', s_monthly_forecast_message;

  /* code ends for monthly forecast */

  forecast_data_as_json := concat('"forecast": [{"todays_forecast_text": "', s_daily_forecast_message, '","todays_forecast_image": "', s_daily_forecast_image,  '","monthly_forecast_text": "', s_monthly_forecast_message, '","monthly_forecast_image": "', s_monthly_forecast_image, '"}]'); 

--transactions
  s_sqlquery_recent_transactions := concat(s_sqlquery_recent_transactions, app_user_id,s_sqlquery_recent_transactions_orderby, ') row' );
  RAISE INFO 's_sqlquery_recent_transactions sql: <%>', s_sqlquery_recent_transactions;
  BEGIN
    EXECUTE s_sqlquery_recent_transactions into transactions_data_as_json; 
    IF transactions_data_as_json is NULl THEN 
      transactions_data_as_json :=concat('', '[]');
    END IF; 
    
    transactions_data_as_json := concat('"transactions": ', transactions_data_as_json);
  EXCEPTION WHEN OTHERS THEN
      transactions_data_as_json :=concat('"transactions": ', '[]');
  END;

--spend_by_category

  s_sqlquery_spend_by_category := concat(s_sqlquery_spend_by_category, app_user_id,s_sqlquery_spend_by_category_orderby, ') row' );
  RAISE INFO 's_sqlquery_spend_by_category sql: <%>', s_sqlquery_spend_by_category;

  BEGIN
    EXECUTE s_sqlquery_spend_by_category into spend_by_category_data_as_json; 

    IF spend_by_category_data_as_json is NULl THEN 
      spend_by_category_data_as_json :=concat('', '[]');
    END IF; 

    spend_by_category_data_as_json := concat('"spend_by_category": ', spend_by_category_data_as_json);
    
  EXCEPTION WHEN OTHERS THEN
      spend_by_category_data_as_json :=concat('"spend_by_category": ', '[]');
  END;

--subscriptions 

  s_sqlquery_subscriptions := concat(s_sqlquery_subscriptions, app_user_id,s_sqlquery_subscriptions_orderby, ') row' );
  RAISE INFO 's_sqlquery_subscriptions : <%>', s_sqlquery_subscriptions;
  BEGIN
    EXECUTE s_sqlquery_subscriptions into subscriptions_data_as_json; 
    IF subscriptions_data_as_json is NULl THEN 
      subscriptions_data_as_json :=concat('', '[]');
    END IF; 
    subscriptions_data_as_json := concat('"subscriptions": ', subscriptions_data_as_json);
    
  EXCEPTION
    WHEN NO_DATA_FOUND then  
      subscriptions_data_as_json :=concat('"subscriptions": ', '[]');
    WHEN OTHERS THEN
      subscriptions_data_as_json :=concat('"subscriptions": ', '[]');
  END;

--utilization

  s_sqlquery_utilization := concat(s_sqlquery_utilization, app_user_id, ') row' );
  --RAISE INFO 's_sqlquery_utilization in insights : <%>', s_sqlquery_utilization;
  BEGIN
    EXECUTE s_sqlquery_utilization into utilization_data_as_json; 
    IF utilization_data_as_json is NULl THEN 
      utilization_data_as_json :=concat('', '[]');
    END IF; 
    utilization_data_as_json := concat('"utilization": ', utilization_data_as_json);
    
  EXCEPTION 
  WHEN OTHERS THEN
      utilization_data_as_json :=concat('"utilization": ', '[]');
  END;

--improve_credit

  s_sqlquery_improve_credit := concat(s_sqlquery_improve_credit, app_user_id, s_improve_credit_where );
  --RAISE INFO 's_sqlquery_improve_credit : <%>', s_sqlquery_improve_credit;
  BEGIN
    EXECUTE s_sqlquery_improve_credit into s_display_message, s_display_notes, s_voice_message, s_account_data_as_json;
    RAISE INFO 's_account_data_as_json inside inssights: <%>', s_account_data_as_json;
    
    IF s_account_data_as_json is NULl THEN 
      s_account_data_as_json :=concat('', '[]');
    END IF;

    improve_credit_data_as_json := concat('"improve_credit": ', s_account_data_as_json, ',"improve_credit_text": [{"improve_credit_text": "',s_display_message, '"}]' );
    RAISE INFO 'improve_credit_data_as_json : <%>', improve_credit_data_as_json;

  EXCEPTION WHEN OTHERS THEN
    RAISE INFO 'improve_credit_data_as_json inside exception : <%>', improve_credit_data_as_json;
    improve_credit_data_as_json :=concat('"improve_credit": ', '[]');
  END;

--card_recommendation
  s_user_query_text := 'whats a good card to use for shopping asking from insightssssssssss';
  s_amount_for_card_reco :='0';
  select * from insert_into_user_query_tear_down (app_user_id , s_user_query_text , 'ios' , 'insights' , 'user_insights' , 'completed', null, null ,null ,null , null , null , null) into n_query_tear_down_id; 
  RAISE INFO ' n_query_tear_down_id    : <%>', n_query_tear_down_id; 

  IF n_query_tear_down_id is not null THEN 
    select * from get_card_recommendations(n_query_tear_down_id, app_user_id, s_user_query_text, s_amount_for_card_reco) into card_recommendation_data_as_json;
    --RAISE INFO ' card_recommendation_data_as_json from insights    : <%>', card_recommendation_data_as_json; 
     IF card_recommendation_data_as_json is NULl THEN 
      card_recommendation_data_as_json :=concat('', '[]');
     ELSE 
       card_recommendation_data_as_json :=concat( '"card_recommendation_categories": [{"default_category": "Shopping", "category1": "Travel", "category1_query": "whats a good card to use for travel", "category2": "Gas", "category2_query": "whats a good card to use for gas", "category3": "Restaurants", "category3_query": "whats a good card to use for restaurants"}], "card_recommendation": ',card_recommendation_data_as_json);
    END IF;
  END IF; 

--interest_paid
 s_sqlquery_interest_paid := concat(s_sqlquery_interest_paid, app_user_id, ') row' );
  RAISE INFO 's_sqlquery_interest_paid : <%>', s_sqlquery_interest_paid;
  BEGIN
    EXECUTE s_sqlquery_interest_paid into interest_paid_data_as_json; 
    IF interest_paid_data_as_json is NULl THEN 
      interest_paid_data_as_json :=concat('', '[]');
    END IF;

    -- IF not found then interest_paid_data_as_json :=concat('', '[]');
    -- END IF;
    interest_paid_data_as_json := concat('"interest_paid": ', interest_paid_data_as_json);
  EXCEPTION WHEN OTHERS THEN
      interest_paid_data_as_json :=concat('"interest_paid": ', '[]');
  END;

END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_user_insights(app_user_id IN integer, OUT snapshot_output_as_json text, OUT forecast_data_as_json text, OUT transactions_data_as_json text, OUT spend_by_category_data_as_json text, OUT utilization_data_as_json text, OUT improve_credit_data_as_json text, OUT card_recommendation_data_as_json text, OUT subscriptions_data_as_json text, OUT interest_paid_data_as_json text) OWNER TO evadev;

--******************--

--Function Name: get_user_query_results
-- Purpose: Function to get results of a user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_user_query_results(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, OUT results_json text)
AS $$
DECLARE 
--global variables definition
r record; 
user_scenario text;
counter integer :=0; 
intent_name text :=NULL;
intent_desc text;
intent_type text;
utterance_keywords text;
display_screen_name text;
display_type text;
query_id text; 
display_message text; 
voice_message text; 
display_value text; 
display_notes text; 
--s_display_notes text; 
p_query_status text :='completed'; 
from_date text; 
to_date text; 
s_amount text; 
plaid_account_name text; 
matched_account_name_keyword text;
plaid_account_subtype text; 
plaid_institution_id text; 
matched_institution_name text;
category_levels_to_check text; 
category_level0 text; 
category_level1 text;
category_level2 text; 
ending_number text; 
txn_biz_name text; 
results_from_function text :=null; 
transaction_output_as_json text :=null; 
graph_data_as_json text :=null;
account_data_as_json text; 
card_reco_data_as_json text; 
--json outputs for insights page
snapshot_data_as_json text; 
forecast_data_as_json text;  
transactions_data_as_json text; 
spend_by_category_data_as_json text;  
utilization_data_as_json text;  
improve_credit_data_as_json text;  
card_recommendation_data_as_json text;  
subscriptions_data_as_json text;  
interest_paid_data_as_json text;

sqlwhere  text := null;
sqlquery_string text := null;
sqlorderby text := null;
sqlgroupby text := null;
s_user_nickname text := null; 
s_user_name text; 
matched_category_keyword text;
matched_date_keyword  text;
s_matched_biz_name_keyword text;
matched_date_display text := null; 
matched_bizname_display text :=null;
n_utilization_value numeric := null;
s_utilization_message text :=null;
s_utilization_voice_message text :=null;
s_query_id integer; 
eva_emoji text := ''; -- ':information_desk_person: '
s_insights_json_output text; -- this is to store the insights json from the build_insights_json_output 
s_sqlquery_total_cash text := ' select cast(round(sum(a.available_balance),0) as money) from plaidmanager_account a where a.account_sub_type = ''checking'' and a.deleted_at is null and ';
s_sqlquery_snapshot_where text := ' user_id = ';
s_sqlquery_total_outstanding_balance text := ' select cast(round(sum(a.current_balance),0) as money) from plaidmanager_account a where a.account_sub_type = ''credit card'' and a.deleted_at is null and '; 
s_sqlquery_utilization text := ' select concat(round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%'') from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i  ';     
s_sqlwhere text;   
s_total_cash text; 
s_total_outstanding_balance text; 
s_utilization_value text;
s_sentiment text;

BEGIN  
    IF (p_user_id IS NULL) OR (p_user_query_text IS NULL) THEN 
        display_message := 'Sorry, I am having some trouble processing your request. Please try again after some time.';    
        display_screen_name := 'results_screen'; 
        display_type :='message';
    ELSE 

        BEGIN 
            select first_name from users_user where id = p_user_id into s_user_nickname; 
            RAISE INFO 'User nickname: <%>', s_user_nickname;
        EXCEPTION WHEN OTHERS THEN 
            s_user_nickname := NULL;  
            --RAISE INFO 'inside user nickname exception : <%>', s_user_nickname;
        END; 
        BEGIN 
            SELECT * from get_user_sentiment_from_query(p_user_id, p_user_query_text, p_query_mode, p_query_source) INTO s_sentiment;
            RAISE INFO 'user sentiment <%>', s_sentiment;
        EXCEPTION WHEN OTHERS THEN 
            s_sentiment := NULL;  
        END;

        FOR r IN SELECT * FROM configure_intent order by id asc LOOP
            IF ((regexp_matches(concat(' ', lower(p_user_query_text), ' '), lower(r.keywords), 'g'))[1]) IS NOT NULL THEN
                
                intent_name := r.code; 
                display_screen_name := r.display_screen_name; 
                display_type := r.display_type;

                IF r.is_date_check THEN  
                 SELECT * from get_date_from_user_query(p_user_query_text) INTO from_date, to_date, matched_date_keyword;
                 IF matched_date_keyword IS NOT NULL THEN 
                  --matched_date_display := concat (' between ', to_char(from_date::date, 'DD Month YYYY'), ' and ', to_char(to_date::date, 'DD Month YYYY'), ' ');
                  matched_date_display := concat (' during ' , matched_date_keyword); 
                 ELSE 
                  matched_date_display := concat('', '');
                 END IF; 
                END IF;   
                IF r.is_account_name_check THEN    
                    SELECT * from get_account_name_from_user_query(p_user_query_text) INTO plaid_account_name, matched_account_name_keyword ;          
                END IF;   
                IF r.is_charge_category_check THEN
                    select * from get_charge_category_from_user_query(p_user_query_text) into category_levels_to_check,category_level0,category_level1,category_level2,matched_category_keyword ;
                END IF;   
            /*    IF r.card_reco_category_check THEN 
                    select * from get_card_reco_category_from_user_query(p_user_query_text) into category_levels_to_check,category_level0,category_level1,category_level2,matched_category_keyword ;
                END IF; 
                */
                --RAISE INFO 'Txn biz name check: <%>', r.is_transaction_biz_name_check;
                IF r.is_transaction_biz_name_check THEN
                    select * from get_txn_biz_name_from_user_query(p_user_query_text,p_user_id) into txn_biz_name;
                END IF;  
                --RAISE INFO 'general_biz_name_check : <%>', r.is_general_biz_name_check ;   
                IF r.is_general_biz_name_check THEN 
                  IF txn_biz_name IS NULL THEN
                    select * from get_biz_name_from_user_query(p_user_query_text) into txn_biz_name, s_matched_biz_name_keyword;
                  ELSE 
                  END IF;   
                END IF;
                IF txn_biz_name IS NOT NULL THEN 
                  matched_bizname_display := concat (' at ', initcap(txn_biz_name) ,' ');
                 ELSE 
                  matched_bizname_display := concat('', '');
                 END IF;                    
                IF r.is_amount_check THEN
                 select * from get_amount_from_user_query(p_user_query_text) into s_amount;
                END IF; 
                IF r.is_account_ending_check THEN 
                    select * from get_account_ending_number_from_user_query(p_user_query_text, p_user_id) into ending_number;
                END IF; 
                IF r.is_account_subtype_check THEN 
                    select * from get_account_subtype_from_user_query(p_user_query_text) into plaid_account_subtype;
                END IF; 
                IF r.is_institution_type_check THEN 
                    select * from get_institution_id_from_user_query(p_user_query_text) into plaid_institution_id, matched_institution_name;
                END IF; 
                --IF r.card_name_check THEN
                    --call get_card_from_query
                --END IF; 


                RAISE INFO 'Intent Name: <%>', intent_name;
                RAISE INFO 'Intent Desc: <%>', intent_desc;
                RAISE INFO 'Intent Type: <%>', intent_type;
                RAISE INFO 'display screen: <%>', display_screen_name;
                RAISE INFO 'display type: <%>', display_type;
                RAISE INFO 'From date : <%>', from_date;
                RAISE INFO 'To date : <%>', to_date; 
                RAISE INFO 'Amount: <%>', s_amount; 
                RAISE INFO 'Plaid Account Name: <%>', plaid_account_name; 
                RAISE INFO 'Plaid Account sub type: <%>', plaid_account_subtype; 
                RAISE INFO 'Plaid Account ending: <%>', ending_number;
                RAISE INFO 'Plaid Institution Id: <%>', plaid_institution_id;
                RAISE INFO 'Plaid Institution Name: <%>', matched_institution_name;
                RAISE INFO 'category level: <%>', category_levels_to_check;
                RAISE INFO 'category 0: <%>', category_level0;
                RAISE INFO 'category1: <%>', category_level1; 
                RAISE INFO 'category2: <%>', category_level2;
                RAISE INFO 'txn biz name: <%>', txn_biz_name; 
                RAISE INFO 'account ending number: <%>', ending_number;

                --consolidate all parameters and call the right functions

                CASE lower(intent_name)
                    WHEN 'welcome_message' THEN 
                      IF (s_user_nickname IS NOT NULL) THEN 
                          display_message:= concat('Hey  ', s_user_nickname, ', hows it going? How can I help you today?');
                      ELSE 
                          display_message:= 'Hey! Hows it going? How can I help you today?';
                      END IF;  
                    WHEN 'available_balance' THEN  
                      BEGIN
                          select * from get_available_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the available balance for your criteria.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the available balance for your criteria.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your available balance is ', display_value);
                              voice_message:= concat ('Your available balance is ', display_value);
                              display_type := 'accounts_green';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END; 
                    WHEN 'daily_briefing' THEN  
                      BEGIN
                        s_sqlquery_total_cash := concat(s_sqlquery_total_cash, s_sqlquery_snapshot_where, p_user_id); 
                        BEGIN
                          EXECUTE s_sqlquery_total_cash into s_total_cash; 
                          IF s_total_cash IS NULL THEN 
                            s_total_cash :='Unavailable';
                          END IF; 

                        EXCEPTION WHEN OTHERS THEN
                            s_total_cash :='Unavailable';
                        END;
                        
                        s_sqlquery_total_outstanding_balance := concat(s_sqlquery_total_outstanding_balance, s_sqlquery_snapshot_where, p_user_id); 
                        BEGIN
                          EXECUTE s_sqlquery_total_outstanding_balance into s_total_outstanding_balance; 
                          IF s_total_outstanding_balance IS NULL THEN 
                            s_total_outstanding_balance :='Unavailable';
                          END IF; 

                        EXCEPTION WHEN OTHERS THEN
                            s_total_outstanding_balance :='Unavailable';
                        END;

                        s_sqlwhere := concat(' where 1 = 1 and lower(a.account_sub_type) in ( ''credit card'') and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and a.user_id =   ', p_user_id );  

                        s_sqlquery_utilization := concat(s_sqlquery_utilization, s_sqlwhere); 
                        BEGIN
                          EXECUTE s_sqlquery_utilization into s_utilization_value; 
                          IF s_utilization_value IS NULL THEN 
                            s_utilization_value :='Unavailable';
                          END IF; 

                        EXCEPTION WHEN OTHERS THEN
                            s_utilization_value :='Unavailable';
                        END;

                        select * from get_available_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;

                        display_message:= concat ( s_user_nickname, ', your total cash is ', s_total_cash, ', your total payoff outstanding is ', s_total_outstanding_balance, ', and your overall credit usage is at ', s_utilization_value, '.');
                        voice_message:= display_message;
                        display_type := 'accounts_green';
                          
                        IF (account_data_as_json IS NULL) and (s_total_cash = 'Unavailable') and (s_total_outstanding_balance = 'Unavailable') and  (s_utilization_value = 'Unavailable') THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the daily briefing information for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the daily briefing information for you', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                        END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END;

                    WHEN 'credit_card_listing' THEN  
                      BEGIN
                          select * from get_credit_card_listing(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the credit card listing for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the credit card listing for you.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is a listing of your credit cards and the associated available balance for each card');
                              voice_message:= concat (eva_emoji, 'Here is a listing of your credit cards and the associated available balance for each card');
                              display_type := 'accounts_green';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END;     

                      WHEN 'improve_credit_score' THEN 
                        BEGIN 
                          display_type := 'accounts_porange';
                          select * from get_improve_credit_score (p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_message, display_notes, voice_message, account_data_as_json;
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                          -- voice_message := display_message; 
                          display_message := concat (eva_emoji,display_message);
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END; 
                      WHEN 'high_yield_savings' THEN 
                        BEGIN 
                          display_type := 'message_image';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'Saving money can be a real challenge but here is how you can earn a high interest rate on your money.';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'be_first_values' THEN 
                        BEGIN 
                          display_type := 'message_image_vision';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'Berkshire Bank is driven to build a successful and meaningful culture by providing an open environment where everyone can thrive through people first based employment, business and altruistic practices.';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'budget_groceries_dining_out' THEN 
                        BEGIN 
                          display_type := 'message_image_budget';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'Most people budget 6% for groceries each month and 5% for dining out. If your take-home income is $3,000 a month, you will budget around $180 for groceries and $150 for dining.';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'how_much_savings_each_month' THEN 
                        BEGIN 
                          display_type := 'message_image_saving';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'As a general rule, you should try to save 20% of your income, using the formula 50/30/20. 50% of your income pays your fixed expenses. 30% of your income pays your variable expenses. You should then save 20% of your income.';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'how_long_switch_to_nbs_takes' THEN 
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat (s_user_nickname, ', the switch process normally takes less than 7 days. Here are some information that will help you make the switch. ', null); 
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 
                          display_notes :=concat( ':point_right: More information available  <a href=\"https://www.nationwide.co.uk/products/current-accounts/our-current-accounts/switch#how-can-i-switch\">here</a><br><br> :point_right: Thinking about switching? Switching your bank or building society current account means you open a new account and your old account is closed. All your existing payments are moved from your old account to your new current account.', null);

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'military_savings_berskshire' THEN 
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message :=  null; 
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 
                          display_notes :=concat( ':point_right: Berkshire Bank is proud to offer a high-ranking savings account to current and former members of the armed services. You will have freedom from fees, earn interest on deposits and be able to access your money from wherever you are stationed with Online Banking and Mobile Banking tools. <br><br> :point_right: More information available  <a href=\"https://www.berkshirebank.com/Personal/Banking/Savings-CDs/eXciting-Military-Savings\">here</a><br><br> ', null);

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'nbs_switching_process' THEN 
                        BEGIN 
                          display_type := 'message_image';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'Here is how the switch process will happen. Tap on the image to get more details';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'switch_to_nbs' THEN 
                        BEGIN 
                          display_type := 'message_form';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'We are glad you are switching to Nationwide. Please complete the following information to get started.';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'credit_protection' THEN 
                        BEGIN 
                          display_type := 'credit_protection';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'I am glad you took advantage of this, especially at this time. We can help you activate the service since this works like your insurance on your credit card. Would you like to avail this?';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'lost_job_repayment_options' THEN 
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( s_user_nickname, ', I am sorry to hear that you lost your job :disappointed: and are going through some tough times right now. Let us see if there is anything I can do to help you out. In the meantime, can you please verify your address? ', null); 
                          voice_message := concat ( s_user_nickname, ', I am sorry to hear that you lost your job and are going through some tough times right now. Let us see if there is anything I can do to help you out. In the meantime, can you please verify your address?', null);
                          --RAISE INFO 'resulting display notes : <%>', display_notes;

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'address_verification' THEN 
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Thanks for the verification! Here are some offers that you can leverage: ', null); 
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 
                          display_notes :=concat( ':point_right: Credit Protection: <a href=\"https://www.google.com\">Good news! Looks like you are enrolled and eligible to avail this offer</a><br><br> :point_right: LSFW: <a href=\"https://www.google.com\">Tap here to know more about this offer. Just say LSFW to avail this offer</a><br><br> :point_right: Re age: <a href=\"https://www.google.com\">Tap here to know more about this offer.</a><br><br>:point_right: Date Out: <a href=\"https://www.google.com\">Tap here to know more about this offer.</a><br><br>', null);
                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'make_a_payment' THEN 
                        BEGIN 
                          display_type := 'message';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( s_user_nickname, ', glad to know you would like to make a payment :thumbsup:. Before we get started, can you please confirm the last four digits of your Social Security number?', null); 
                          voice_message := concat ( s_user_nickname, ', glad to know you would like to make a payment. Before we get started, can you please confirm the last four digits of your Social Security number?', null); 
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'social_security' THEN 
                        BEGIN 
                          display_type := 'message';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Thanks ', s_user_nickname, '! How much would you like to pay towards your payment?', null); 
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'payment_200' THEN
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Thanks ', s_user_nickname, '! May we suggest you pay $240 as this is your minimum due at this time :blush:? ', null); 
                          voice_message := concat ( 'Thanks ', s_user_nickname, '! May we suggest you pay $240 as this is your minimum due at this time? ', null); 
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'payment_240' THEN 
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Great! How would you like to make the payment? Here are some options for you', null); 
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 
                          display_notes :=concat( ':point_right: Debit Card  <a href=\"https://www.google.com\">Tap here to enter your Debit Card details</a><br><br> :point_right: Checking Account: Just Say Checking Account and the payment will be processed automatically from your connected Checking Account', null);
                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'payment_with_checking_account' THEN 
                        BEGIN 
                          display_type := 'message';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Nice job ', s_user_nickname, ':clap::clap::clap:! You are all set now! Your payment will be processed in 1-2 days. Thanks for your time.', null); 
                          voice_message := concat ( 'Nice job ', s_user_nickname, '! You are all set now! Your payment will be processed in 1-2 days. Thanks for your time.', null); 
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 
                
                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'credit_lsfw' THEN 
                        BEGIN 
                          display_type := 'credit_lsfw';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ('I have great news for you ', s_user_nickname , '. As of the moment, we can see that you have an offer on the account to clear up your balance and save money. Instead of paying for the full balance, we just need to make a payment of $214.89 by 20th December and we are all set.');
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'view_utilization' THEN 
                        BEGIN
                          select * from get_utilization(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          IF (display_value is null) OR (display_value = '%') THEN 
                              n_utilization_value :=' currently unavailable '; 
                          ELSE 
                              n_utilization_value := to_number(display_value, '99.9'); 
                              IF n_utilization_value <=9 THEN 
                                  s_utilization_message := ' Excellent job on keeping your utilization under control :clap::clap::clap:'; 
                                  s_utilization_voice_message := ' Excellent job on keeping your utilization under control'; 
                              ELSIF n_utilization_value BETWEEN 9 AND 29 THEN 
                                  s_utilization_message := ' Very good job on keeping your utilization low. :clap::clap:'; 
                                  s_utilization_voice_message := ' Very good job on keeping your utilization low'; 
                              ELSIF n_utilization_value BETWEEN 29 AND 49 THEN
                                  s_utilization_message := ' Good job on keeping your utilization less than 50%.:clap:'; 
                                  s_utilization_voice_message := ' Good job on keeping your utilization less than 50%'; 
                              ELSIF n_utilization_value BETWEEN 49 AND 75 THEN 
                                  s_utilization_message := ' Fair job on keeping your utilization less than 75%.'; 
                                  s_utilization_voice_message := ' Fair job on keeping your utilization less than 75%.'; 

                              ELSIF n_utilization_value >75 THEN 
                                  s_utilization_message := ' Watch out, you are approaching your maximum utilization :exclamation:'; 
                                  s_utilization_voice_message := ' Watch out, you are approaching your maximum utilization'; 

                              ELSE 
                                  s_utilization_message :=NULL;
                              END IF;     
                          END IF; 
                          --RAISE INFO 'resulting utilization accounts json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message; 
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your current utilization is ', display_value, '.', s_utilization_message);
                              voice_message:= concat ('Your current utilization is ', display_value, '.', s_utilization_voice_message);
                              --voice_message := display_message;
                              IF n_utilization_value <= 35 THEN 
                                display_type := 'accounts_ured';
                              ELSIF n_utilization_value BETWEEN 35 and 70 THEN 
                                display_type := 'accounts_ured';
                              ELSIF n_utilization_value BETWEEN 70 and 100 THEN
                                display_type := 'accounts_ured';
                              ELSE 
                                display_type := 'accounts_ured';
                              END IF;
                          END IF; 
                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message; 
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END; 
                     WHEN 'credit_limit' THEN
                      BEGIN
                          select * from get_credit_limit(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting credit limit account json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the credit limit for your criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji,'The credit limit for your criteria is ', display_value);
                              voice_message := concat ('The credit limit for your criteria is ', display_value);
                              display_type := 'accounts_green';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END; 
                    WHEN 'credit_card_payments' THEN 
                      BEGIN     
                          select * from get_credit_card_payments(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have made credit card payments of ', display_value, '. Here are the associated payment transactions.');
                              voice_message := concat ('You have made credit card payments of ', display_value, '. Here are the associated payment transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have made credit card payments of ', display_value);
                              voice_message := concat ( 'You have made credit card payments of ', display_value);
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no credit card payments for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;


                      WHEN 'debit_transactions' THEN 
                      BEGIN     
                          select * from get_debit_transactions(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('Here are your recent debit transactions.');
                              voice_message := concat ('Here are your recent debit transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('Here are your recent debit transactions.');
                              voice_message := concat ('Here are your recent debit transactions.');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no debit transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END; 
                     WHEN 'how_can_i_save_money' THEN  

                      BEGIN 
                        display_type := 'message_notes';
                        select * from get_how_can_i_save_money(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_message, display_notes, voice_message;
                        voice_message := display_message;
                        display_message := concat(eva_emoji, display_message); 
                        --RAISE INFO 'resulting message : <%>', display_message; 
                        --RAISE INFO 'resulting display notes : <%>', display_notes; 

                        EXCEPTION WHEN OTHERS THEN
                                display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                voice_message := display_message;
                                display_type := 'message';
                                p_query_status := 'incomplete';
                      END;     
                     WHEN 'view_transactions' THEN 
                      BEGIN     
                          select * from get_transactions_json(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there werent any transactions for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here are your transactions ', matched_bizname_display, matched_date_display , null);
                              voice_message := concat (eva_emoji, 'Here are your transactions ', matched_bizname_display, matched_date_display , null);
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              display_type := 'message';
                              voice_message := display_message;
                              p_query_status := 'incomplete';
                      END;  

                      WHEN 'view_credit_card_transactions' THEN 
                        BEGIN     
                          select * from get_credit_card_transactions(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there werent any credit card transactions for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_type := 'message_transaction';
                              display_message:= concat (eva_emoji, 'Here are your credit card transaction details..', null);
                              voice_message := concat ('Here are your credit card transaction details..', null);
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              display_type := 'message';
                              voice_message := display_message;
                              p_query_status := 'incomplete';
                      END;  
                      WHEN 'card_reco' THEN  
                        BEGIN
                          --RAISE INFO 'inside card reco : <%>', p_user_id; 
                
                          display_message:= concat('Here are your card recommendations');   
                          voice_message :=  concat('Here are your card recommendations');                  
                          display_type :='card_recommendation'; 
                          select * from insert_into_user_query_tear_down (p_user_id , p_user_query_text, p_query_source , p_query_mode , intent_name , p_query_status, display_type, display_message ,display_value ,display_notes , transaction_output_as_json , graph_data_as_json , results_json) into s_query_id; 
                          RAISE INFO ' insert_into_user_query_tear_down returns the query id : <%>', s_query_id; 

                          IF s_query_id is not null THEN 
                              select * from get_card_recommendations (s_query_id,p_user_id, p_user_query_text, s_amount ) into card_reco_data_as_json;
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          s_query_id :=null; 
                      END;   
                    WHEN 'how_much_interest_have_i_paid' THEN 
                      BEGIN     
                          select * from get_interest_paid(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              IF lower(s_sentiment) = 'angry' THEN 
                                display_message:= concat (s_user_nickname, ', completely understand your concern about the interest charges for ', display_value, '. However these are charges levied by the bank towards your outstanding balance. Paying off more on the outstanding balance will bring down penalties and interest charges.');
                                voice_message:= concat (s_user_nickname, ', completely understand your concern about the interest charges for ', display_value, '. However these are charges levied by the bank towards your outstanding balance.');
                              ELSE 
                                display_message:= concat (eva_emoji, 'You have paid ', display_value, ' as interest. Here are the associated charges.');
                                voice_message := concat ('You have paid ', display_value, ' as interest. Here are the associated charges.');
                              END IF; 

                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'You have paid ', display_value, ' as interest. Here are the associated charges.');
                              voice_message := concat ('You have paid ', display_value, ' as interest. Here are the associated charges.');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no transactions for your criteria.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', there were no transactions for your criteria.', null); 
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END; 
                    WHEN 'last_thing_bought' THEN 
                      BEGIN     
                          select * from get_last_thing_bought(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no transactions for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here are your last bought transactions', null);
                              voice_message := concat ( 'Here are your last bought transactions', null);
                              display_type := 'message_transaction';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;   
                    WHEN 'last_visit' THEN 
                      BEGIN     
                          select * from get_last_visit(p_user_query_text, p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              voice_message := concat ('Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              voice_message := concat ('Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there werent any transactions for that criteria.', null);
                              voice_message := display_message; 
                              p_query_status := 'incomplete';
                              display_type := 'message';  
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;                   
                             
                    WHEN 'monthly_average_spending' THEN 
                      BEGIN
                          select * from get_monthly_average_spending(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is your monthly average spend information ');
                              voice_message := concat ( 'Here is your monthly average spend information ');
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END; 
 
                   WHEN 'yearly_average_spending' THEN 
                      BEGIN
                          select * from get_yearly_average_spending(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is your yearly average spend information ');
                              voice_message := concat ( 'Here is your yearly average spend information ');
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END; 
                   WHEN 'weekly_average_spending' THEN 
                      BEGIN
                          select * from get_weekly_average_spending(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is your weekly average spend information ');
                              voice_message := concat ( 'Here is your weekly average spend information ');
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END;
                    WHEN 'future_financial_status' THEN 
                      BEGIN
                          select * from get_future_financial_status(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get that information for you.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (s_user_nickname, ', given your current income, and a saving potential of 20%, this will be your financial projection for the future.');
                              voice_message := display_message;
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get that information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END;   
                    WHEN 'credit_card_payment_due' THEN 
                      BEGIN     
                          select * from get_next_payment_date(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          IF display_value is NOT NULL THEN 
                          --select (case when date(display_value) = date(now()) THEN 'Today' ELSE

                               display_value := concat(substr(rtrim(initcap(to_char(date(display_value), 'day'))),1, 9),', ', date_part('day', date(display_value)),' ', substr(rtrim(to_char(date(display_value), 'Month')),1,9),' ', EXTRACT(YEAR FROM date(display_value)));  
                          END IF; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting new display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Based on your past payments, it appears your payment due is ', display_value, '. Here are some of your most recent payments.');
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Based on your past payments, it appears your next payment due is ', display_value);
                              display_type := 'message';
                              voice_message := display_message;
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 
                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;                       
                    WHEN 'outstanding_balance' THEN 
                      BEGIN
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting outstanding balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the outstanding balance information for you.', null); 
                              display_type := 'message';
                              p_query_status := 'incomplete'; 
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your current outstanding balance is ', display_value);
                              voice_message := concat ('Your current outstanding balance is ', display_value);
                              display_type := 'accounts_ored';
                          END IF; 
                          
                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END;
                    WHEN 'transfer_from_current_savings' THEN  
                      BEGIN
                          display_screen_name := intent_name;
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          display_value := s_amount;
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE
                            IF p_query_language = 'en' THEN 
                                display_screen_name := intent_name;
                                display_message:= concat ('Are you sure you would like to initiate the transfer', '', '?');
                                voice_message:= concat ('Are you sure you would like to initiate the transfer', '', '?');
                            ELSE 
                                display_message:= concat ('Are you sure you would like to initiate the transfer', '', '?');
                                voice_message:= concat ('Are you sure you would like to initiate the transfer', '', '?');  
                              END IF;
                              display_type := 'message';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END;  
                    WHEN 'bill_payment' THEN  
                      BEGIN
                          display_screen_name := intent_name;
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          display_value := s_amount;
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE
                            IF p_query_language = 'en' THEN 
                                display_screen_name := intent_name;
                                display_message:= concat ('Are you sure you would like to initiate the bill payment', '', '?');
                                voice_message:= concat ('Are you sure you would like to initiate the bill payment', '', '?');
                            ELSE 
                                display_message:= concat ('Are you sure you would like to initiate the bill payment', '', '?');
                                voice_message:= concat ('Are you sure you would like to initiate the bill payment', '', '?');  
                              END IF;
                              display_type := 'message';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END;    
                    WHEN 'schedule_bill_payments' THEN  
                      BEGIN
                          display_screen_name := intent_name;
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          display_value := s_amount;
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE
                            IF p_query_language = 'en' THEN 
                                display_screen_name := intent_name;
                                display_message:= concat ('Are you sure you would like to schedule the bill payment', '', '?');
                                voice_message:= concat ('Are you sure you would like to schedule the bill payment', '', '?');
                            ELSE 
                                display_message:= concat ('Are you sure you would like to schedule the bill payment', '', '?');
                                voice_message:= concat ('Are you sure you would like to schedule the bill payment', '', '?');  
                              END IF;
                              display_type := 'message';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END;     
                    WHEN 'purchasing_transactions' THEN 
                      BEGIN     
                          select * from get_purchasing_transactions(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I could not find any related transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSIF (matched_date_keyword = 'recent') or  (matched_date_keyword = 'recently') THEN 
                              display_message:= concat (eva_emoji,'Here are your recent purchases ', matched_bizname_display);
                              voice_message := concat ('Here are your recent purchases ', matched_bizname_display);
                              display_type := 'message_transaction';

                          ELSE 
                              display_message:= concat (eva_emoji,'Here are the purchasing transactions for your criteria', null);
                              voice_message := concat ('Here are the purchasing transactions for your criteria..', null);
                              display_type := 'message_transaction';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;    
                    WHEN 'recurring_charges' THEN 
                      BEGIN     
                          select * from get_recurring_charges(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no recurring charges for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji,'Here are your recurring charges information', null);
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null);
                              voice_message := display_message; 
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;   
                    WHEN 'spend_by_category' THEN 
                      BEGIN
                          select * from get_spend_by_category(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji,'Here is your spend by category information');
                              voice_message := concat ('Here is your spend by category information');
                              display_type := 'message_piechart';
                              display_notes := display_value;
                          END IF;
                       EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END;
                    WHEN 'spend_check' THEN 
                      BEGIN     
                          select * from get_spend_check(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'You have spent ', display_value, matched_bizname_display , matched_date_display, '. Here are the associated transactions.');
                              voice_message := concat (eva_emoji,'You have spent ', display_value, matched_bizname_display , matched_date_display, '. Here are the associated transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji, 'You have spent ', display_value);
                              voice_message := concat ( 'You have spent ', display_value);
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I could not find any ', matched_bizname_display, ' related transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;
                    WHEN 'atm_related_transactions' THEN 
                      BEGIN     
                          select * from get_atm_withdrawals(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 
                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have withdrawn ', display_value, ' from the ATM. Here are the transactions.');
                              voice_message := concat ('You have withdrawn ', display_value, ' from the ATM. Here are the transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have withdrawn ', display_value, ' from the ATM.');
                              voice_message := concat ('You have withdrawn ', display_value, ' from the ATM.');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no ATM transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;   
                    WHEN 'user_earnings' THEN 
                      BEGIN     
                          select * from get_user_earnings(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have a total earning of ', display_value, '. Here are the related transactions.');
                              voice_message := concat ('You have a total earning of ', display_value, '. Here are the related transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have a total earning of ', display_value, '');
                              voice_message := concat ('You have a total earning of ', display_value, ' ');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no relevant transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;  
                     WHEN 'subscriptions' THEN 
                      BEGIN
                          select * from get_subscription_charges(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no subscription related charges for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here are your subscription related charges ', null);
                              voice_message := concat ('Here are your subscription related charges ', null);
                              display_type := 'message_transaction';
                          END IF;
                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END; 
                    WHEN 'net_worth' THEN 
                      BEGIN
                          select * from get_user_net_worth(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting net worth json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the net worth information.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your net worth is ', display_value, '. ');
                              voice_message := concat ( 'Your net worth is ', display_value, '. ');
                              display_type := 'message';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END;
                    WHEN 'account_balance' THEN 
                      BEGIN
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting outstanding balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for your criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your account balance is ', display_value);
                              voice_message := concat ('Your account balance is ', display_value);
                              display_type := 'accounts_ored';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message';
                          voice_message := display_message;
                          p_query_status := 'incomplete';

                      END; 
                    WHEN 'user_insights' THEN
                      BEGIN
                        select * from get_user_insights (p_user_id) into snapshot_data_as_json, forecast_data_as_json, transactions_data_as_json, spend_by_category_data_as_json, utilization_data_as_json, improve_credit_data_as_json, card_recommendation_data_as_json, subscriptions_data_as_json, interest_paid_data_as_json;

                      EXCEPTION WHEN OTHERS THEN 

                      END;         
                    /*  

                    WHEN 'can_i_spend_scenario' THEN 
                      display_message:='all well for can_i_spend_scenario';                  
                   

                    WHEN 'how_am_i_doing' THEN 
                      display_message:='all well for how_am_i_doing';                    


                    */
                    ELSE
                      display_message:='Sorry, I was unable to gather the information for your request.'; 
                      display_type := 'message_error';

                END CASE;

                EXIT;  -- to make sure only the first intent gets executed..

            ELSE 
                --  do a run of all checks such as account sub type, category, txn_biz_type and account name type and call get_transactions 
                -- this will be a IF ELSE END IF for each condition . This will help in cases where user just says costco or starbucks or coffee or blue cash 
                IF (s_user_nickname IS NOT NULL) THEN 
                    display_message:= concat('Sorry ', s_user_nickname, ', I was unable to get that information for you. Here are some other things that I can help you with');
                    voice_message := display_message;

                ELSE
                    display_message := 'Sorry, I was unable to gather the information for your request.';
                    voice_message := display_message;
                END IF; 
                display_screen_name := 'results_screen'; 
                display_type :='message_error';
            END IF;

         END LOOP;
    END IF;

    BEGIN 
      IF (intent_name = 'card_reco') THEN 
        --not needed to insert again into user_query_tear_down as this was already done in the card_reco function
      ELSE 
        select * from insert_into_user_query_tear_down (p_user_id , p_user_query_text, p_query_source , p_query_mode , intent_name , p_query_status, display_type, display_message ,display_value ,display_notes , transaction_output_as_json , graph_data_as_json , results_json) into s_query_id;  
        RAISE INFO 's_query_id ttt: <%>', s_query_id;
      END IF;
      
    EXCEPTION WHEN OTHERS THEN 
      s_query_id :=null;
    END;

    IF intent_name = 'user_insights' THEN 
      --RAISE INFO 'before building insights json: <%>', intent_name; 
      --RAISE INFO 's_query_id: <%>', s_query_id; 
      --RAISE INFO 'snapshot_data_as_json building insights json: <%>', snapshot_data_as_json; 
      --RAISE INFO 'forecast_data_as_json building insights json: <%>', forecast_data_as_json; 
      --RAISE INFO 'transactions_data_as_json building insights json: <%>', transactions_data_as_json; 
      --RAISE INFO 'spend_by_category_data_as_json building insights json: <%>', spend_by_category_data_as_json; 
      --RAISE INFO 'utilization_data_as_json building insights json: <%>', utilization_data_as_json; 
      --RAISE INFO 'improve_credit_data_as_json building insights json: <%>', improve_credit_data_as_json; 
      --RAISE INFO 'card_recommendation_data_as_json building insights json: <%>', card_recommendation_data_as_json; 
      --RAISE INFO 'subscriptions_data_as_json building insights json: <%>', subscriptions_data_as_json; 
      --RAISE INFO 'interest_paid_data_as_json building insights json: <%>', interest_paid_data_as_json; 

      BEGIN
        select * from build_insights_json_output (s_query_id, snapshot_data_as_json, transactions_data_as_json, subscriptions_data_as_json, spend_by_category_data_as_json, utilization_data_as_json, interest_paid_data_as_json, improve_credit_data_as_json, card_recommendation_data_as_json, forecast_data_as_json) into results_json;
        --RAISE INFO 'resulting build_insights_json text: <%>', s_insights_json_output; 
        --RAISE INFO 'resulting results_json text: <%>', results_json; 

      EXCEPTION WHEN OTHERS THEN 

        s_insights_json_output :='{"header": {"query_id": "exception"}}';
      END;
      --results_json := s_insights_json_output;
    ELSE 
      select * from build_json_output (query_id, p_user_query_text, display_screen_name, display_type, display_message, voice_message, display_value, display_notes, transaction_output_as_json, graph_data_as_json , account_data_as_json, card_reco_data_as_json) into results_json;

    END IF; 
    --RAISE INFO 'resulting json text: <%>', results_json; 
     /* -- if there are no matching intents based on the match up to the intent master, check to see if we can look for biz name or date or charge category keywords. 
            Based on that, call appropriate functions 
        IF (intent_name IS NULL THEN)
            ----RAISE INFO 'No matching intents..<%>', intent_name;
            -- check if the user mentioned about charge category check (like 'cafe last month' or 'coffee last month')
            -- check if user mentioned any business name ('coscto', 'starbucks last month')
            -- do a date check to see if user mentioned any dates or timeline ('starbucks last month', 'travel spend last month')
            -- now use the parameters to call a db function..(perhaps a default function that will get a summary of spend along with the transaction information )
            IF charge_category is not null and  d_from_date is not null and , d_to_date
        END IF; 
     */
  /*    
*/        
EXCEPTION WHEN OTHERS THEN 
    
    IF (s_user_nickname IS NOT NULL) THEN 
        display_message:= concat('Sorry ', s_user_nickname, ', I am having some trouble processing your request. Please try again after some time.');
    ELSE
         display_message := 'Sorry, I am having some trouble processing your request. Please try again after some time.';
    END IF; 
    display_screen_name := 'results_screen'; 
    display_type :='message';

    select * from build_json_output (query_id, p_user_query_text, display_screen_name, display_type, display_message, voice_message, display_value, display_notes, transaction_output_as_json, graph_data_as_json , account_data_as_json, card_reco_data_as_json) into results_json; 

    --RAISE INFO 'resulting json text: <%>', results_json;    
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_user_query_results(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, OUT results_json text) OWNER TO evadev;

--******************--

CREATE OR REPLACE FUNCTION get_user_sentiment_results(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, OUT sentiment text)
AS $$
DECLARE 
--global variables definition
    r record; 
    user_scenario text;
    counter integer :=0; 

BEGIN  
    IF (p_user_id IS NULL) OR (p_user_query_text IS NULL) THEN 
        sentiment := '';
    ELSE 
        sentiment := '';
        FOR r IN SELECT * FROM configure_sentiments order by id asc LOOP
            RAISE INFO 'inside for loop: <%>', sentiment;
            IF ((regexp_matches(concat(' ', lower(p_user_query_text), ' '), lower(r.sentiment_keywords), 'g'))[1]) IS NOT NULL THEN
                sentiment := r.sentiment_code; 
                RAISE INFO 'Sentiment Code: <%>', sentiment;
            END IF;
        END LOOP;
    END IF; 
    sentiment := concat('{','"', 'user_query', '"', ':', '"', p_user_query_text, '"', ', "', 'sentiment', '"', ':', '"', sentiment, '"', '}');

EXCEPTION WHEN OTHERS THEN 
      sentiment := '';
      sentiment := concat('{','"', 'user_query', '"', ':', '"', p_user_query_text, '"', ', "', 'sentiment', '"', ':', '"', sentiment, '"', '}');
      RAISE INFO 'inside EXCEPTION: <%>', sentiment;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_user_sentiment_results(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, OUT sentiment text) OWNER TO evadev;


--******************--

CREATE OR REPLACE FUNCTION get_user_sentiment_from_query(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, OUT sentiment text)
AS $$
DECLARE 
--global variables definition
    r record; 
    user_scenario text;
    counter integer :=0; 

BEGIN  
    IF (p_user_id IS NULL) OR (p_user_query_text IS NULL) THEN 
        sentiment := '';
    ELSE 
        sentiment := '';
        FOR r IN SELECT * FROM configure_sentiments order by id asc LOOP
            RAISE INFO 'inside for loop: <%>', sentiment;
            IF ((regexp_matches(concat(' ', lower(p_user_query_text), ' '), lower(r.sentiment_keywords), 'g'))[1]) IS NOT NULL THEN
                sentiment := r.sentiment_code; 
                RAISE INFO 'Sentiment Code: <%>', sentiment;
            END IF;
        END LOOP;
    END IF; 
    

EXCEPTION WHEN OTHERS THEN 
      sentiment := '';
      
      RAISE INFO 'inside EXCEPTION: <%>', sentiment;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_user_sentiment_from_query(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, OUT sentiment text) OWNER TO evadev;


--******************--


CREATE OR REPLACE FUNCTION get_intent_from_user_query(p_client_id IN text, p_client_secret IN text, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, OUT intent_name text)
AS $$
DECLARE 
--global variables definition
    r record; 
    counter integer :=0; 

BEGIN  

    IF (p_client_id IS NULL) OR (p_client_secret IS NULL) THEN 
        intent_name := 'undefined';
    ELSE 
        intent_name := 'undefined';
        FOR r IN SELECT * FROM configure_intent order by id asc LOOP
            RAISE INFO 'inside for loop: <%>', intent_name;
            IF ((regexp_matches(concat(' ', lower(p_user_query_text), ' '), lower(r.keywords), 'g'))[1]) IS NOT NULL THEN
                intent_name := r.code; 
                RAISE INFO 'Intent Name: <%>', intent_name;
            END IF;
        END LOOP;
    END IF; 
    intent_name := concat('{', '"', 'user_query', '"', ':', '"', p_user_query_text, '"', ', "', 'intent_name', '"', ':', '"', intent_name, '"', '}');

EXCEPTION WHEN OTHERS THEN 
      intent_name := 'undefined';
      intent_name := concat('{', '"', 'user_query', '"', ':', '"', p_user_query_text, '"', ', "', 'intent_name', '"', ':', '"', intent_name, '"', '}');
      RAISE INFO 'inside EXCEPTION: <%>', intent_name;
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_intent_from_user_query(p_client_id IN text, p_client_secret IN text, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, OUT intent_name text) OWNER TO evadev;


--******************--

--Function Name: get_user_query_results_with_sentiment
-- Purpose: Function to get results of a user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_user_query_results_with_sentiment(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, p_query_sentiment IN text, OUT results_json text)
AS $$
DECLARE 
--global variables definition
r record; 
user_scenario text;
counter integer :=0; 
intent_name text :=NULL;
intent_desc text;
intent_type text;
utterance_keywords text;
display_screen_name text;
display_type text;
query_id text; 
display_message text; 
voice_message text; 
display_value text; 
display_notes text; 
--s_display_notes text; 
p_query_status text :='completed'; 
from_date text; 
to_date text; 
s_amount text; 
plaid_account_name text; 
matched_account_name_keyword text;
plaid_account_subtype text; 
plaid_institution_id text; 
matched_institution_name text;
category_levels_to_check text; 
category_level0 text; 
category_level1 text;
category_level2 text; 
ending_number text; 
txn_biz_name text; 
results_from_function text :=null; 
transaction_output_as_json text :=null; 
graph_data_as_json text :=null;
account_data_as_json text; 
card_reco_data_as_json text; 
--json outputs for insights page
snapshot_data_as_json text; 
forecast_data_as_json text;  
transactions_data_as_json text; 
spend_by_category_data_as_json text;  
utilization_data_as_json text;  
improve_credit_data_as_json text;  
card_recommendation_data_as_json text;  
subscriptions_data_as_json text;  
interest_paid_data_as_json text;

sqlwhere  text := null;
sqlquery_string text := null;
sqlorderby text := null;
sqlgroupby text := null;
s_user_nickname text := null; 
s_user_name text; 
matched_category_keyword text;
matched_date_keyword  text;
s_matched_biz_name_keyword text;
matched_date_display text := null; 
matched_bizname_display text :=null;
n_utilization_value numeric := null;
s_utilization_message text :=null;
s_utilization_voice_message text :=null;
s_query_id integer; 
eva_emoji text := ''; -- ':information_desk_person: '
s_insights_json_output text; -- this is to store the insights json from the build_insights_json_output 
s_sqlquery_total_cash text := ' select cast(round(sum(a.available_balance),0) as money) from plaidmanager_account a where a.account_sub_type = ''checking'' and a.deleted_at is null and ';
s_sqlquery_snapshot_where text := ' user_id = ';
s_sqlquery_total_outstanding_balance text := ' select cast(round(sum(a.current_balance),0) as money) from plaidmanager_account a where a.account_sub_type = ''credit card'' and a.deleted_at is null and '; 
s_sqlquery_utilization text := ' select concat(round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%'') from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i  ';     
s_sqlwhere text;   
s_total_cash text; 
s_total_outstanding_balance text; 
s_utilization_value text;

BEGIN  
    IF (p_user_id IS NULL) OR (p_user_query_text IS NULL) THEN 
        display_message := 'Sorry, I am having some trouble processing your request. Please try again after some time.';    
        display_screen_name := 'results_screen'; 
        display_type :='message';
    ELSE 

        BEGIN 
            select first_name from users_user where id = p_user_id into s_user_nickname; 
            RAISE INFO 'User nickname: <%>', s_user_nickname;
        EXCEPTION WHEN OTHERS THEN 
            s_user_nickname := NULL;  
            --RAISE INFO 'inside user nickname exception : <%>', s_user_nickname;
        END; 

        FOR r IN SELECT * FROM configure_intent order by id asc LOOP
            IF ((regexp_matches(concat(' ', lower(p_user_query_text), ' '), lower(r.keywords), 'g'))[1]) IS NOT NULL THEN
                
                intent_name := r.code; 
                display_screen_name := r.display_screen_name; 
                display_type := r.display_type;

                IF r.is_date_check THEN  
                 SELECT * from get_date_from_user_query(p_user_query_text) INTO from_date, to_date, matched_date_keyword;
                 IF matched_date_keyword IS NOT NULL THEN 
                  --matched_date_display := concat (' between ', to_char(from_date::date, 'DD Month YYYY'), ' and ', to_char(to_date::date, 'DD Month YYYY'), ' ');
                  matched_date_display := concat (' during ' , matched_date_keyword); 
                 ELSE 
                  matched_date_display := concat('', '');
                 END IF; 
                END IF;   
                IF r.is_account_name_check THEN    
                    SELECT * from get_account_name_from_user_query(p_user_query_text) INTO plaid_account_name, matched_account_name_keyword ;          
                END IF;   
                IF r.is_charge_category_check THEN
                    select * from get_charge_category_from_user_query(p_user_query_text) into category_levels_to_check,category_level0,category_level1,category_level2,matched_category_keyword ;
                END IF;   
            /*    IF r.card_reco_category_check THEN 
                    select * from get_card_reco_category_from_user_query(p_user_query_text) into category_levels_to_check,category_level0,category_level1,category_level2,matched_category_keyword ;
                END IF; 
                */
                --RAISE INFO 'Txn biz name check: <%>', r.is_transaction_biz_name_check;
                IF r.is_transaction_biz_name_check THEN
                    select * from get_txn_biz_name_from_user_query(p_user_query_text,p_user_id) into txn_biz_name;
                END IF;  
                --RAISE INFO 'general_biz_name_check : <%>', r.is_general_biz_name_check ;   
                IF r.is_general_biz_name_check THEN 
                  IF txn_biz_name IS NULL THEN
                    select * from get_biz_name_from_user_query(p_user_query_text) into txn_biz_name, s_matched_biz_name_keyword;
                  ELSE 
                  END IF;   
                END IF;
                IF txn_biz_name IS NOT NULL THEN 
                  matched_bizname_display := concat (' at ', initcap(txn_biz_name) ,' ');
                 ELSE 
                  matched_bizname_display := concat('', '');
                 END IF;                    
                IF r.is_amount_check THEN
                 select * from get_amount_from_user_query(p_user_query_text) into s_amount;
                END IF; 
                IF r.is_account_ending_check THEN 
                    select * from get_account_ending_number_from_user_query(p_user_query_text, p_user_id) into ending_number;
                END IF; 
                IF r.is_account_subtype_check THEN 
                    select * from get_account_subtype_from_user_query(p_user_query_text) into plaid_account_subtype;
                END IF; 
                IF r.is_institution_type_check THEN 
                    select * from get_institution_id_from_user_query(p_user_query_text) into plaid_institution_id, matched_institution_name;
                END IF; 
                --IF r.card_name_check THEN
                    --call get_card_from_query
                --END IF; 

                RAISE INFO 'Intent Name: <%>', intent_name;
                RAISE INFO 'Intent Desc: <%>', intent_desc;
                RAISE INFO 'Intent Type: <%>', intent_type;
                RAISE INFO 'display screen: <%>', display_screen_name;
                RAISE INFO 'display type: <%>', display_type;
                RAISE INFO 'From date : <%>', from_date;
                RAISE INFO 'To date : <%>', to_date; 
                RAISE INFO 'Amount: <%>', s_amount; 
                RAISE INFO 'Plaid Account Name: <%>', plaid_account_name; 
                RAISE INFO 'Plaid Account sub type: <%>', plaid_account_subtype; 
                RAISE INFO 'Plaid Account ending: <%>', ending_number;
                RAISE INFO 'Plaid Institution Id: <%>', plaid_institution_id;
                RAISE INFO 'Plaid Institution Name: <%>', matched_institution_name;
                RAISE INFO 'category level: <%>', category_levels_to_check;
                RAISE INFO 'category 0: <%>', category_level0;
                RAISE INFO 'category1: <%>', category_level1; 
                RAISE INFO 'category2: <%>', category_level2;
                RAISE INFO 'txn biz name: <%>', txn_biz_name; 
                RAISE INFO 'account ending number: <%>', ending_number;

                --consolidate all parameters and call the right functions

                CASE lower(intent_name)
                    WHEN 'welcome_message' THEN 
                      IF (s_user_nickname IS NOT NULL) THEN 
                          display_message:= concat('Hey  ', s_user_nickname, ', hows it going? How can I help you today?');
                      ELSE 
                          display_message:= 'Hey! Hows it going? How can I help you today?';
                      END IF;  
                    WHEN 'available_balance' THEN  
                      BEGIN
                          select * from get_available_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the available balance for your criteria.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the available balance for your criteria.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your available balance is ', display_value);
                              voice_message:= concat ('Your available balance is ', display_value);
                              display_type := 'accounts_green';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END; 
                     WHEN 'card_block' THEN  
                      BEGIN
                        display_message:= concat (eva_emoji, 'Your card has been successfully blocked. You are all set! ', display_value);
                        voice_message:= concat ('Your card has been successfully blocked. You are all set! ', display_value);
                        display_type := 'message';
                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';
                      END;   
                    WHEN 'daily_briefing' THEN  
                      BEGIN
                        s_sqlquery_total_cash := concat(s_sqlquery_total_cash, s_sqlquery_snapshot_where, p_user_id); 
                        BEGIN
                          EXECUTE s_sqlquery_total_cash into s_total_cash; 
                          IF s_total_cash IS NULL THEN 
                            s_total_cash :='Unavailable';
                          END IF; 

                        EXCEPTION WHEN OTHERS THEN
                            s_total_cash :='Unavailable';
                        END;
                        
                        s_sqlquery_total_outstanding_balance := concat(s_sqlquery_total_outstanding_balance, s_sqlquery_snapshot_where, p_user_id); 
                        BEGIN
                          EXECUTE s_sqlquery_total_outstanding_balance into s_total_outstanding_balance; 
                          IF s_total_outstanding_balance IS NULL THEN 
                            s_total_outstanding_balance :='Unavailable';
                          END IF; 

                        EXCEPTION WHEN OTHERS THEN
                            s_total_outstanding_balance :='Unavailable';
                        END;

                        s_sqlwhere := concat(' where 1 = 1 and lower(a.account_sub_type) in ( ''credit card'') and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and a.user_id =   ', p_user_id );  

                        s_sqlquery_utilization := concat(s_sqlquery_utilization, s_sqlwhere); 
                        BEGIN
                          EXECUTE s_sqlquery_utilization into s_utilization_value; 
                          IF s_utilization_value IS NULL THEN 
                            s_utilization_value :='Unavailable';
                          END IF; 

                        EXCEPTION WHEN OTHERS THEN
                            s_utilization_value :='Unavailable';
                        END;

                        select * from get_available_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;

                        display_message:= concat ( s_user_nickname, ', your total cash is ', s_total_cash, ', your total payoff outstanding is ', s_total_outstanding_balance, ', and your overall credit usage is at ', s_utilization_value, '.');
                        voice_message:= display_message;
                        display_type := 'accounts_green';
                          
                        IF (account_data_as_json IS NULL) and (s_total_cash = 'Unavailable') and (s_total_outstanding_balance = 'Unavailable') and  (s_utilization_value = 'Unavailable') THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the daily briefing information for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the daily briefing information for you', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                        END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END;

                    WHEN 'credit_card_listing' THEN  
                      BEGIN
                          select * from get_credit_card_listing(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the credit card listing for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the credit card listing for you.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is a listing of your credit cards and the associated available balance for each card');
                              voice_message:= concat (eva_emoji, 'Here is a listing of your credit cards and the associated available balance for each card');
                              display_type := 'accounts_green';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END;     

                      WHEN 'improve_credit_score' THEN 
                        BEGIN 
                          display_type := 'accounts_porange';
                          select * from get_improve_credit_score (p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_message, display_notes, voice_message, account_data_as_json;
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                          -- voice_message := display_message; 
                          display_message := concat (eva_emoji,display_message);
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END; 
                      WHEN 'high_yield_savings' THEN 
                        BEGIN 
                          display_type := 'message_image';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'Saving money can be a real challenge but here is how you can earn a high interest rate on your money.';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'nbs_switching_process' THEN 
                        BEGIN 
                          display_type := 'message_image';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'Here is how the switch process will happen. Tap on the image to get more details';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'view_utilization' THEN 
                        BEGIN
                          select * from get_utilization(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          IF (display_value is null) OR (display_value = '%') THEN 
                              n_utilization_value :=' currently unavailable '; 
                          ELSE 
                              n_utilization_value := to_number(display_value, '99.9'); 
                              IF n_utilization_value <=9 THEN 
                                  s_utilization_message := ' Excellent job on keeping your utilization under control :clap::clap::clap:'; 
                                  s_utilization_voice_message := ' Excellent job on keeping your utilization under control'; 
                              ELSIF n_utilization_value BETWEEN 9 AND 29 THEN 
                                  s_utilization_message := ' Very good job on keeping your utilization low. :clap::clap:'; 
                                  s_utilization_voice_message := ' Very good job on keeping your utilization low'; 
                              ELSIF n_utilization_value BETWEEN 29 AND 49 THEN
                                  s_utilization_message := ' Good job on keeping your utilization less than 50%.:clap:'; 
                                  s_utilization_voice_message := ' Good job on keeping your utilization less than 50%'; 
                              ELSIF n_utilization_value BETWEEN 49 AND 75 THEN 
                                  s_utilization_message := ' Fair job on keeping your utilization less than 75%.'; 
                                  s_utilization_voice_message := ' Fair job on keeping your utilization less than 75%.'; 

                              ELSIF n_utilization_value >75 THEN 
                                  s_utilization_message := ' Watch out, you are approaching your maximum utilization :exclamation:'; 
                                  s_utilization_voice_message := ' Watch out, you are approaching your maximum utilization'; 

                              ELSE 
                                  s_utilization_message :=NULL;
                              END IF;     
                          END IF; 
                          --RAISE INFO 'resulting utilization accounts json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message; 
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your current utilization is ', display_value, '.', s_utilization_message);
                              voice_message:= concat ('Your current utilization is ', display_value, '.', s_utilization_voice_message);
                              --voice_message := display_message;
                              IF n_utilization_value <= 35 THEN 
                                display_type := 'accounts_ured';
                              ELSIF n_utilization_value BETWEEN 35 and 70 THEN 
                                display_type := 'accounts_ured';
                              ELSIF n_utilization_value BETWEEN 70 and 100 THEN
                                display_type := 'accounts_ured';
                              ELSE 
                                display_type := 'accounts_ured';
                              END IF;
                          END IF; 
                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message; 
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END; 
                     WHEN 'credit_limit' THEN
                      BEGIN
                          select * from get_credit_limit(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting credit limit account json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the credit limit for your criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji,'The credit limit for your criteria is ', display_value);
                              voice_message := concat ('The credit limit for your criteria is ', display_value);
                              display_type := 'accounts_green';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END; 
                    WHEN 'credit_card_payments' THEN 
                      BEGIN     
                          select * from get_credit_card_payments(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have made credit card payments of ', display_value, '. Here are the associated payment transactions.');
                              voice_message := concat ('You have made credit card payments of ', display_value, '. Here are the associated payment transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have made credit card payments of ', display_value);
                              voice_message := concat ( 'You have made credit card payments of ', display_value);
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no credit card payments for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;


                      WHEN 'debit_transactions' THEN 
                      BEGIN     
                          select * from get_debit_transactions(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('Here are your recent debit transactions.');
                              voice_message := concat ('Here are your recent debit transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('Here are your recent debit transactions.');
                              voice_message := concat ('Here are your recent debit transactions.');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no debit transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END; 
                     WHEN 'how_can_i_save_money' THEN  

                      BEGIN 
                        display_type := 'message_notes';
                        select * from get_how_can_i_save_money(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_message, display_notes, voice_message;
                        voice_message := display_message;
                        display_message := concat(eva_emoji, display_message); 
                        --RAISE INFO 'resulting message : <%>', display_message; 
                        --RAISE INFO 'resulting display notes : <%>', display_notes; 

                        EXCEPTION WHEN OTHERS THEN
                                display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                voice_message := display_message;
                                display_type := 'message';
                                p_query_status := 'incomplete';
                      END;     
                     WHEN 'view_transactions' THEN 
                      BEGIN     
                          select * from get_transactions_json(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there werent any transactions for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here are your transactions ', matched_bizname_display, matched_date_display , null);
                              voice_message := concat (eva_emoji, 'Here are your transactions ', matched_bizname_display, matched_date_display , null);
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              display_type := 'message';
                              voice_message := display_message;
                              p_query_status := 'incomplete';
                      END;  

                      WHEN 'view_credit_card_transactions' THEN 
                        BEGIN     
                          select * from get_credit_card_transactions(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there werent any credit card transactions for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_type := 'message_transaction';
                              display_message:= concat (eva_emoji, 'Here are your credit card transaction details..', null);
                              voice_message := concat ('Here are your credit card transaction details..', null);
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              display_type := 'message';
                              voice_message := display_message;
                              p_query_status := 'incomplete';
                      END;  
                      WHEN 'card_reco' THEN  
                        BEGIN
                          --RAISE INFO 'inside card reco : <%>', p_user_id; 
                
                          display_message:= concat('Here are your card recommendations');   
                          voice_message :=  concat('Here are your card recommendations');                  
                          display_type :='card_recommendation'; 
                          select * from insert_into_user_query_tear_down (p_user_id , p_user_query_text, p_query_source , p_query_mode , intent_name , p_query_status, display_type, display_message ,display_value ,display_notes , transaction_output_as_json , graph_data_as_json , results_json) into s_query_id; 
                          RAISE INFO ' insert_into_user_query_tear_down returns the query id : <%>', s_query_id; 

                          IF s_query_id is not null THEN 
                              select * from get_card_recommendations (s_query_id,p_user_id, p_user_query_text, s_amount ) into card_reco_data_as_json;
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          s_query_id :=null; 
                      END;   
                    WHEN 'how_much_interest_have_i_paid' THEN 
                      BEGIN     
                          select * from get_interest_paid(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              IF lower(p_query_sentiment) = 'angry' THEN 
                                display_message:= concat (s_user_nickname,  ', understand your concern :smile: . The interest related charges have been levied for your outstanding balance ', display_value, '. Here are the associated charges.');
                              ELSE   
                                display_message:= concat (eva_emoji, 'You have paid ', display_value, ' as interest. Here are the associated charges.');
                              END IF;

                              voice_message := concat ('You have paid ', display_value, ' as interest. Here are the associated charges.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'You have paid ', display_value, ' as interest. Here are the associated charges.');
                              voice_message := concat ('You have paid ', display_value, ' as interest. Here are the associated charges.');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no transactions for your criteria.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', there were no transactions for your criteria.', null); 
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END; 
                    WHEN 'last_thing_bought' THEN 
                      BEGIN     
                          select * from get_last_thing_bought(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no transactions for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here are your last bought transactions', null);
                              voice_message := concat ( 'Here are your last bought transactions', null);
                              display_type := 'message_transaction';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;   
                    WHEN 'last_visit' THEN 
                      BEGIN     
                          select * from get_last_visit(p_user_query_text, p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              voice_message := concat ('Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              voice_message := concat ('Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there werent any transactions for that criteria.', null);
                              voice_message := display_message; 
                              p_query_status := 'incomplete';
                              display_type := 'message';  
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;                   
                             
                    WHEN 'monthly_average_spending' THEN 
                      BEGIN
                          select * from get_monthly_average_spending(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is your monthly average spend information ');
                              voice_message := concat ( 'Here is your monthly average spend information ');
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END; 
 
                   WHEN 'yearly_average_spending' THEN 
                      BEGIN
                          select * from get_yearly_average_spending(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is your yearly average spend information ');
                              voice_message := concat ( 'Here is your yearly average spend information ');
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END; 
                   WHEN 'weekly_average_spending' THEN 
                      BEGIN
                          select * from get_weekly_average_spending(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is your weekly average spend information ');
                              voice_message := concat ( 'Here is your weekly average spend information ');
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END;
                    WHEN 'future_financial_status' THEN 
                      BEGIN
                          select * from get_future_financial_status(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get that information for you.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (s_user_nickname, ', given your current income, and a saving potential of 20%, this will be your financial projection for the future.');
                              voice_message := display_message;
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get that information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END;   
                    WHEN 'credit_card_payment_due' THEN 
                      BEGIN     
                          select * from get_next_payment_date(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          IF display_value is NOT NULL THEN 
                          --select (case when date(display_value) = date(now()) THEN 'Today' ELSE

                               display_value := concat(substr(rtrim(initcap(to_char(date(display_value), 'day'))),1, 9),', ', date_part('day', date(display_value)),' ', substr(rtrim(to_char(date(display_value), 'Month')),1,9),' ', EXTRACT(YEAR FROM date(display_value)));  
                          END IF; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting new display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Based on your past payments, it appears your payment due is ', display_value, '. Here are some of your most recent payments.');
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Based on your past payments, it appears your next payment due is ', display_value);
                              display_type := 'message';
                              voice_message := display_message;
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 
                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;                       
                    WHEN 'outstanding_balance' THEN 
                      BEGIN
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting outstanding balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the outstanding balance information for you.', null); 
                              display_type := 'message';
                              p_query_status := 'incomplete'; 
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your current outstanding balance is ', display_value);
                              voice_message := concat ('Your current outstanding balance is ', display_value);
                              display_type := 'accounts_ored';
                          END IF; 
                          
                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END;
                    WHEN 'purchasing_transactions' THEN 
                      BEGIN     
                          select * from get_purchasing_transactions(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I could not find any related transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSIF (matched_date_keyword = 'recent') or  (matched_date_keyword = 'recently') THEN 
                              display_message:= concat (eva_emoji,'Here are your recent purchases ', matched_bizname_display);
                              voice_message := concat ('Here are your recent purchases ', matched_bizname_display);
                              display_type := 'message_transaction';

                          ELSE 
                              display_message:= concat (eva_emoji,'Here are the purchasing transactions for your criteria', null);
                              voice_message := concat ('Here are the purchasing transactions for your criteria..', null);
                              display_type := 'message_transaction';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;    
                    WHEN 'recurring_charges' THEN 
                      BEGIN     
                          select * from get_recurring_charges(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no recurring charges for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji,'Here are your recurring charges information', null);
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null);
                              voice_message := display_message; 
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;   
                    WHEN 'spend_by_category' THEN 
                      BEGIN
                          select * from get_spend_by_category(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji,'Here is your spend by category information');
                              voice_message := concat ('Here is your spend by category information');
                              display_type := 'message_piechart';
                              display_notes := display_value;
                          END IF;
                       EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END;
                    WHEN 'spend_check' THEN 
                      BEGIN     
                          select * from get_spend_check(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'You have spent ', display_value, matched_bizname_display , matched_date_display, '. Here are the associated transactions.');
                              voice_message := concat (eva_emoji,'You have spent ', display_value, matched_bizname_display , matched_date_display, '. Here are the associated transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji, 'You have spent ', display_value);
                              voice_message := concat ( 'You have spent ', display_value);
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I could not find any ', matched_bizname_display, ' related transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;
                    WHEN 'atm_related_transactions' THEN 
                      BEGIN     
                          select * from get_atm_withdrawals(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 
                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have withdrawn ', display_value, ' from the ATM. Here are the transactions.');
                              voice_message := concat ('You have withdrawn ', display_value, ' from the ATM. Here are the transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have withdrawn ', display_value, ' from the ATM.');
                              voice_message := concat ('You have withdrawn ', display_value, ' from the ATM.');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no ATM transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;   
                    WHEN 'user_earnings' THEN 
                      BEGIN     
                          select * from get_user_earnings(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have a total earning of ', display_value, '. Here are the related transactions.');
                              voice_message := concat ('You have a total earning of ', display_value, '. Here are the related transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have a total earning of ', display_value, '');
                              voice_message := concat ('You have a total earning of ', display_value, ' ');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no relevant transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;  
                     WHEN 'subscriptions' THEN 
                      BEGIN
                          select * from get_subscription_charges(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no subscription related charges for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here are your subscription related charges ', null);
                              voice_message := concat ('Here are your subscription related charges ', null);
                              display_type := 'message_transaction';
                          END IF;
                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END; 
                    WHEN 'net_worth' THEN 
                      BEGIN
                          select * from get_user_net_worth(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting net worth json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the net worth information.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your net worth is ', display_value, '. ');
                              voice_message := concat ( 'Your net worth is ', display_value, '. ');
                              display_type := 'message';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END;
                    WHEN 'account_balance' THEN 
                      BEGIN
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting outstanding balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for your criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your account balance is ', display_value);
                              voice_message := concat ('Your account balance is ', display_value);
                              display_type := 'accounts_ored';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message';
                          voice_message := display_message;
                          p_query_status := 'incomplete';

                      END; 
                    WHEN 'user_insights' THEN
                      BEGIN
                        select * from get_user_insights (p_user_id) into snapshot_data_as_json, forecast_data_as_json, transactions_data_as_json, spend_by_category_data_as_json, utilization_data_as_json, improve_credit_data_as_json, card_recommendation_data_as_json, subscriptions_data_as_json, interest_paid_data_as_json;

                      EXCEPTION WHEN OTHERS THEN 

                      END;         
                    /*  

                    WHEN 'can_i_spend_scenario' THEN 
                      display_message:='all well for can_i_spend_scenario';                  
                   

                    WHEN 'how_am_i_doing' THEN 
                      display_message:='all well for how_am_i_doing';                    


                    */
                    ELSE
                      display_message:='Sorry, I was unable to gather the information for your request.'; 
                      display_type := 'message_error';

                END CASE;

                EXIT;  -- to make sure only the first intent gets executed..

            ELSE 
                --  do a run of all checks such as account sub type, category, txn_biz_type and account name type and call get_transactions 
                -- this will be a IF ELSE END IF for each condition . This will help in cases where user just says costco or starbucks or coffee or blue cash 
                IF (s_user_nickname IS NOT NULL) THEN 
                    display_message:= concat('Sorry ', s_user_nickname, ', I was unable to get that information for you. Here are some other things that I can help you with');
                    voice_message := display_message;

                ELSE
                    display_message := 'Sorry, I was unable to gather the information for your request.';
                    voice_message := display_message;
                END IF; 
                display_screen_name := 'results_screen'; 
                display_type :='message_error';
            END IF;

         END LOOP;
    END IF;

    BEGIN 
      IF (intent_name = 'card_reco') THEN 
        --not needed to insert again into user_query_tear_down as this was already done in the card_reco function
      ELSE 
        select * from insert_into_user_query_tear_down (p_user_id , p_user_query_text, p_query_source , p_query_mode , intent_name , p_query_status, display_type, display_message ,display_value ,display_notes , transaction_output_as_json , graph_data_as_json , results_json) into s_query_id;  
        RAISE INFO 's_query_id ttt: <%>', s_query_id;
      END IF;
      
    EXCEPTION WHEN OTHERS THEN 
      s_query_id :=null;
    END;

    IF intent_name = 'user_insights' THEN 
      --RAISE INFO 'before building insights json: <%>', intent_name; 
      --RAISE INFO 's_query_id: <%>', s_query_id; 
      --RAISE INFO 'snapshot_data_as_json building insights json: <%>', snapshot_data_as_json; 
      --RAISE INFO 'forecast_data_as_json building insights json: <%>', forecast_data_as_json; 
      --RAISE INFO 'transactions_data_as_json building insights json: <%>', transactions_data_as_json; 
      --RAISE INFO 'spend_by_category_data_as_json building insights json: <%>', spend_by_category_data_as_json; 
      --RAISE INFO 'utilization_data_as_json building insights json: <%>', utilization_data_as_json; 
      --RAISE INFO 'improve_credit_data_as_json building insights json: <%>', improve_credit_data_as_json; 
      --RAISE INFO 'card_recommendation_data_as_json building insights json: <%>', card_recommendation_data_as_json; 
      --RAISE INFO 'subscriptions_data_as_json building insights json: <%>', subscriptions_data_as_json; 
      --RAISE INFO 'interest_paid_data_as_json building insights json: <%>', interest_paid_data_as_json; 

      BEGIN
        select * from build_insights_json_output (s_query_id, snapshot_data_as_json, transactions_data_as_json, subscriptions_data_as_json, spend_by_category_data_as_json, utilization_data_as_json, interest_paid_data_as_json, improve_credit_data_as_json, card_recommendation_data_as_json, forecast_data_as_json) into results_json;
        --RAISE INFO 'resulting build_insights_json text: <%>', s_insights_json_output; 
        --RAISE INFO 'resulting results_json text: <%>', results_json; 

      EXCEPTION WHEN OTHERS THEN 

        s_insights_json_output :='{"header": {"query_id": "exception"}}';
      END;
      --results_json := s_insights_json_output;

    ELSE 
      select * from build_json_output (query_id, p_user_query_text, display_screen_name, display_type, display_message, voice_message, display_value, display_notes, transaction_output_as_json, graph_data_as_json , account_data_as_json, card_reco_data_as_json) into results_json; 

    END IF; 
    --RAISE INFO 'resulting json text: <%>', results_json; 
     /* -- if there are no matching intents based on the match up to the intent master, check to see if we can look for biz name or date or charge category keywords. 
            Based on that, call appropriate functions 
        IF (intent_name IS NULL THEN)
            ----RAISE INFO 'No matching intents..<%>', intent_name;
            -- check if the user mentioned about charge category check (like 'cafe last month' or 'coffee last month')
            -- check if user mentioned any business name ('coscto', 'starbucks last month')
            -- do a date check to see if user mentioned any dates or timeline ('starbucks last month', 'travel spend last month')
            -- now use the parameters to call a db function..(perhaps a default function that will get a summary of spend along with the transaction information )
            IF charge_category is not null and  d_from_date is not null and , d_to_date
        END IF; 
     */
  /*    
*/        
EXCEPTION WHEN OTHERS THEN 
    
    IF (s_user_nickname IS NOT NULL) THEN 
        display_message:= concat('Sorry ', s_user_nickname, ', I am having some trouble processing your request. Please try again after some time.');
    ELSE
         display_message := 'Sorry, I am having some trouble processing your request. Please try again after some time.';
    END IF; 
    display_screen_name := 'results_screen'; 
    display_type :='message';

    select * from build_json_output (query_id, p_user_query_text, display_screen_name, display_type, display_message, voice_message, display_value, display_notes, transaction_output_as_json, graph_data_as_json , account_data_as_json, card_reco_data_as_json) into results_json; 

    --RAISE INFO 'resulting json text: <%>', results_json;    
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_user_query_results_with_sentiment(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, p_query_sentiment IN text, OUT results_json text) OWNER TO evadev;

--******************--


-- ALTER TABLE users_userqueryhistory ADD COLUMN category_levels_to_check text;
-- ALTER TABLE users_userqueryhistory ADD COLUMN category_level0 text;
-- ALTER TABLE users_userqueryhistory ADD COLUMN category_level1 text;
-- ALTER TABLE users_userqueryhistory ADD COLUMN category_level2 text;
-- ALTER TABLE users_userqueryhistory ADD COLUMN txn_biz_name text;
-- ALTER TABLE users_userqueryhistory ADD COLUMN from_date text;
-- ALTER TABLE users_userqueryhistory ADD COLUMN to_date text;
-- ALTER TABLE users_userqueryhistory ADD COLUMN matched_institution_name text; 
-- ALTER TABLE users_userqueryhistory ADD COLUMN amount text;
-- ALTER TABLE users_userqueryhistory ADD COLUMN plaid_account_name text; 
-- ALTER TABLE users_userqueryhistory ADD COLUMN plaid_account_subtype text;
-- ALTER TABLE users_userqueryhistory ADD COLUMN ending_number text;
--******************--

--Function Name: insert_into_user_query_tear_down
-- Purpose: Function to insert new records into user_query_tear_down table 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION insert_into_user_query_tear_down_v1(p_user_id IN integer, p_user_query_text IN text, p_query_source IN text, p_query_mode IN text, p_intent_name IN text, p_query_status IN text, p_display_type IN text, p_display_message IN text, p_display_value IN text, p_display_notes IN text, p_transaction_output_as_json IN text, p_graph_data_as_json IN text, p_results_json IN text, category_levels_to_check IN text, category_level0 IN text, category_level1 IN text, category_level2 IN text, txn_biz_name IN text, from_date IN text, to_date IN text, matched_institution_name IN text, amount IN text, plaid_account_name IN text, plaid_account_subtype IN text, ending_number IN text, OUT s_user_query_id text)
AS $$

DECLARE
  n_user_count smallint; 
  s_display_screen_name text;

BEGIN
  IF (p_user_id IS NOT NULL) THEN 
    BEGIN
      RAISE INFO 'before insert onto  user_query_tear_down <%>', p_user_id;
      IF p_user_query_text IS NULL THEN 
        p_user_query_text := '';
      END IF; 
      IF s_display_screen_name IS NULL THEN 
        s_display_screen_name := '';
      END IF;
      IF p_user_id IS NULL THEN 
        p_user_id := 1;
      END IF;   
      IF p_query_source IS NULL THEN 
        p_query_source := '';
      END IF;
      IF p_query_mode IS NULL THEN 
        p_query_mode := '';
      END IF;
      IF p_intent_name IS NULL THEN 
        p_intent_name := '';
      END IF;
      IF p_query_status IS NULL THEN 
        p_query_status := '';
      END IF;
      IF p_display_type IS NULL THEN 
        p_display_type := '';
      END IF;
      IF p_display_message IS NULL THEN 
        p_display_message := '';
      END IF;
      IF p_display_value IS NULL THEN 
        p_display_value := '';
      END IF;
      IF p_display_notes IS NULL THEN 
        p_display_notes := '';
      END IF;
      IF p_transaction_output_as_json IS NULL THEN 
        p_transaction_output_as_json := '';
      END IF;
      IF p_graph_data_as_json IS NULL THEN 
        p_graph_data_as_json := '';
      END IF;
      IF p_results_json IS NULL THEN 
        p_results_json := '';
      END IF;
      INSERT INTO users_userqueryhistory (user_id, query_text, source, mode, intent_name, status, display_type, display_message, display_value, display_notes, transaction_output_as_json, graph_data_as_json, results_json, created_at, updated_at, display_screen_name, category_levels_to_check, category_level0, category_level1, category_level2, txn_biz_name, from_date, to_date, matched_institution_name, amount, plaid_account_name, plaid_account_subtype, ending_number) values (p_user_id, p_user_query_text, p_query_source, p_query_mode, p_intent_name,  p_query_status, p_display_type, p_display_message,p_display_value, p_display_notes,  p_transaction_output_as_json, p_graph_data_as_json, p_results_json, now(), now(), s_display_screen_name, category_levels_to_check, category_level0, category_level1, category_level2, txn_biz_name, from_date, to_date, matched_institution_name, amount, plaid_account_name, plaid_account_subtype, ending_number) RETURNING id into s_user_query_id; 
      RAISE INFO 'returning user query id  <%>', s_user_query_id;      
    EXCEPTION WHEN OTHERS THEN
      RAISE INFO 'Inside insert exception  <%>', s_user_query_id; 
    END; 
  
  ELSE 
    s_user_query_id := null;
  END IF; 
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION insert_into_user_query_tear_down_v1(p_user_id IN integer, p_user_query_text IN text, p_query_source IN text, p_query_mode IN text, p_intent_name IN text, p_query_status IN text, p_display_type IN text, p_display_message IN text, p_display_value IN text, p_display_notes IN text, p_transaction_output_as_json IN text, p_graph_data_as_json IN text, p_results_json IN text, category_levels_to_check IN text, category_level0 IN text, category_level1 IN text, category_level2 IN text, txn_biz_name IN text, from_date IN text, to_date IN text, matched_institution_name IN text, amount IN text, plaid_account_name IN text, plaid_account_subtype IN text, ending_number IN text, OUT s_user_query_id text) OWNER TO evadev;


--******************--


--Function Name: get_emotion_code_from_user_query
-- Purpose: Function to derive the emotion and associated response from user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_emotion_code_from_user_query(user_query_text IN text, OUT s_emotion_code text, OUT s_media_type text,  OUT s_media_url text,  OUT s_emoji_unicode text)
AS $$

DECLARE
  r text;
  s_emotion_keywords text;
  media_url_array  text ARRAY;
  n_random_number integer; 
  n_array_length integer;

BEGIN
  SELECT parameter_value from configure_globalparameter where parameter_name = 'emotion_codes' and language = 'en' into s_emotion_keywords; 
  FOR r in (select (regexp_matches(concat(' ', lower(user_query_text) , ' '), lower(s_emotion_keywords), 'g'))[1]) LOOP
    SELECT  emotion_code, media_type, media_url, emoji_unicode
    from configure_generic_emotions where lower(emotion_code) = lower(rtrim(ltrim(r))) into s_emotion_code, s_media_type, s_media_url, s_emoji_unicode ;  
  END LOOP;

IF s_media_url IS NOT NULL THEN 
  SELECT string_to_array(s_media_url, '||') into media_url_array;
  select array_length(media_url_array, 1) into n_array_length;
  --RAISE INFO 'array length <%>', n_array_length;
  SELECT floor(random() * n_array_length + 1)::int into n_random_number;
  --RAISE INFO 'random number <%>', n_random_number;
  SELECT media_url_array[n_random_number] into s_media_url;
  --RAISE INFO 's_media_url <%>', s_media_url;
END IF; 

EXCEPTION WHEN OTHERS THEN 
  s_emotion_code :=NULL;
  s_media_type :=NULL; 
  s_media_url :=NULL;
  s_emoji_unicode :=NULL;

END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_emotion_code_from_user_query(user_query_text IN text, OUT s_emotion_code text, OUT s_media_type text,  OUT s_media_url text,  OUT s_emoji_unicode text) OWNER TO evadev;

--*************************--


-- Please note that this function is created only for testing purposes and has no impact on the main function - 16-Apr-2019
--chatbot changes
CREATE OR REPLACE FUNCTION build_message_json_output_v1(query_id IN text, p_user_id IN integer, s_user_nickname IN text, user_query_text IN text, display_screen_name IN text, display_type IN text, display_message IN text, voice_message IN text, display_value IN text, display_notes IN text, p_chat_reference_id IN text, transaction_output_as_json IN text, graph_data_as_json IN text, account_data_as_json IN text, card_reco_data_as_json IN text, OUT json_output text)
AS $$
DECLARE 
--global variables definition
question_json_output text := NULL; 
header_json_output text := NULL; 
body_json_output text := NULL; 
last_message_id numeric := 0;
s_emotion_code text := NULL; 
s_media_type text := NULL; 
s_media_url text := NULL; 
s_emoji_unicode text := NULL;

BEGIN
    IF transaction_output_as_json IS NULL THEN 
      transaction_output_as_json :='[]'; 
    END IF; 
    IF graph_data_as_json IS NULL THEN 
      graph_data_as_json :='[]'; 
    END IF; 
    IF account_data_as_json IS NULL THEN 
        account_data_as_json :='[]'; 
    END IF; 
    IF card_reco_data_as_json IS NULL THEN 
        card_reco_data_as_json :='[]'; 
    END IF; 

  RAISE INFO 'build_message_json_output <%>', p_user_id;

  BEGIN 
    select MAX(message_id) FROM users_chathistory where user_id = p_user_id into last_message_id; 
    IF (last_message_id IS NULL) THEN 
      last_message_id := 0;
    END IF;   
  EXCEPTION WHEN OTHERS THEN 
    last_message_id := 0;  
  END; 

    RAISE INFO 'last_message_id <%>', last_message_id;

    json_output := concat ('[');

    question_json_output = concat ('{ "messageId": ',(last_message_id + 1),', "userID": 1, "userName": "Eva", "avatar": "https://userlogo", "sentDate": "', EXTRACT(EPOCH FROM now()),'" , "body": "',user_query_text,'", "display_type": "message", "reference_id": "', p_chat_reference_id,'" } ');
    json_output := concat (json_output, question_json_output); 
    RAISE INFO ' after question_json_output last_message_id <%>', last_message_id;

    json_output := concat (json_output, ' , ');

    BEGIN 

      select * from get_emotion_code_from_user_query (user_query_text) into s_emotion_code, s_media_type, s_media_url, s_emoji_unicode;

    EXCEPTION WHEN OTHERS THEN 
      s_emotion_code := null; 
      s_media_type := null; 
      s_media_url := null; 
      s_emoji_unicode := null; 
    END; 

    RAISE INFO ' s_emotion_code <%>', s_emotion_code;

    RAISE INFO ' after get_emotion_code_from_user_query display_type <%>', display_type;

    IF (s_emotion_code IS NOT NULL) AND (display_type = 'message_error' ) THEN 
      voice_message := null;
      header_json_output := concat ('{ "messageId": ',(last_message_id + 2),', "userID": "', p_user_id, '", "userName": "', s_user_nickname, '", "avatar": "https://evalogo", "sentDate": "', EXTRACT(EPOCH FROM now()) ,'", "media_url": "',s_media_url, '", "media_type": "',s_media_type, '", "emoji_code": "', s_emoji_unicode, '", "voice_message": "', voice_message, '", "display_type": "message" , "reference_id": "', p_chat_reference_id,'"}');

    ELSE 

      header_json_output := concat ('{ "messageId": ',(last_message_id + 2),', "userID": "', p_user_id, '", "userName": "', s_user_nickname, '", "avatar": "https://evalogo", "sentDate": "', EXTRACT(EPOCH FROM now()) ,'", "body": "', display_message, '", "voice_message": "', voice_message, '", "display_type": "message" , "reference_id": "', p_chat_reference_id,'"}');
    END IF; 
    
    json_output := concat (json_output, header_json_output); 

    RAISE INFO ' after json_output last_message_id <%>', last_message_id;
    --IF display_type = 'message_error' THEN 
    -- this is the placeholder to checking emotions (like thank you, thanks, hi, hello, welcome, awesome, what can eva do, tell me something about eva, etc.)
    -- create a new model called emotion (similar to intent and have media type, media name 1/2/3/4, use randomize to pick a response gif or image) 
    --END IF;

    IF display_type != 'message' and display_type != 'message_error' THEN 
        json_output := concat (json_output, ' , ');
        body_json_output := concat ('{ "messageId": ',(last_message_id + 3),', "userID": "', p_user_id, '", "userName": "', s_user_nickname, '", "avatar": "https://evalogo", "sentDate": "',EXTRACT(EPOCH FROM now())  ,'", "displayType": "', display_type,'" , "reference_id": "', p_chat_reference_id,'" , "kind": {"transactions": ', transaction_output_as_json, ',  "graph_data": ', graph_data_as_json, ', "account_data":', account_data_as_json, ', "card_reco_data":', card_reco_data_as_json, '}}');
        json_output := concat (json_output, body_json_output); 
    END IF; 

    json_output := concat (json_output, ']');

    RAISE INFO 'final json_output <%>', json_output;

    IF (question_json_output IS NOT NULL) THEN 
        INSERT INTO users_chathistory (message_content, message_id, created_at, user_id) values (question_json_output, (last_message_id + 1), now(), p_user_id); 
    END IF;   
    IF (header_json_output IS NOT NULL) THEN 
        INSERT INTO users_chathistory (message_content, message_id, created_at, user_id) values (header_json_output, (last_message_id + 2), now(), p_user_id); 
    END IF;   
    IF (body_json_output IS NOT NULL) THEN 
        INSERT INTO users_chathistory (message_content, message_id, created_at, user_id) values (body_json_output, (last_message_id + 3), now(), p_user_id); 
    END IF;   

    --RAISE INFO 'Result inside build_message_json_output: <%>', json_output; 
EXCEPTION WHEN OTHERS THEN
    display_screen_name :='results_screen'; 
    display_message :='Sorry :worried:, something went wrong, please try again.'; 
    voice_message := 'Sorry, something went wrong, please try again.'; 
    display_type := 'display_message';
    json_output := concat ('{"header": {"query_id": "',query_id, '","user_query_text": "',user_query_text,'","display_screen_name": "', display_screen_name,'","display_type": "', display_type,'","display_message": "', display_message, '","voice_message": "', voice_message, '","display_value": "', display_value,  '","display_notes": "', display_notes, '"}, "transactions": ', transaction_output_as_json, ',  "graph_data":', graph_data_as_json, ', "account_data":', account_data_as_json, ', "card_reco_data":', card_reco_data_as_json, '}');

END;
$$  LANGUAGE plpgsql;


ALTER FUNCTION build_message_json_output_v1(query_id IN text, p_user_id IN integer, s_user_nickname IN text, user_query_text IN text, display_screen_name IN text, display_type IN text, display_message IN text, voice_message IN text, display_value IN text, display_notes IN text, p_chat_reference_id IN text, transaction_output_as_json IN text, graph_data_as_json IN text, account_data_as_json IN text, card_reco_data_as_json IN text, OUT json_output text) OWNER TO evadev;


--******************--

--Function Name: get_user_query_results
-- Purpose: Function to get results of a user query
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_user_query_results_v1(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, p_chat_reference_id IN text, OUT results_json text)
AS $$
DECLARE 
--global variables definition
r record; 
user_scenario text;
counter integer :=0; 
intent_name text :=NULL;
intent_desc text;
intent_type text;
utterance_keywords text;
display_screen_name text;
display_type text;
query_id text; 
display_message text; 
voice_message text; 
display_value text; 
display_notes text; 
--s_display_notes text; 
p_query_status text :='completed'; 
from_date text; 
to_date text; 
s_amount text; 
plaid_account_name text; 
matched_account_name_keyword text;
plaid_account_subtype text; 
plaid_institution_id text; 
matched_institution_name text;
category_levels_to_check text; 
category_level0 text; 
category_level1 text;
category_level2 text; 
ending_number text; 
txn_biz_name text; 
results_from_function text :=null; 
transaction_output_as_json text :=null; 
graph_data_as_json text :=null;
account_data_as_json text; 
card_reco_data_as_json text; 
--json outputs for insights page
snapshot_data_as_json text; 
forecast_data_as_json text;  
transactions_data_as_json text; 
spend_by_category_data_as_json text;  
utilization_data_as_json text;  
improve_credit_data_as_json text;  
card_recommendation_data_as_json text;  
subscriptions_data_as_json text;  
interest_paid_data_as_json text;

sqlwhere  text := null;
sqlquery_string text := null;
sqlorderby text := null;
sqlgroupby text := null;
s_user_nickname text := null; 
s_user_name text; 
matched_category_keyword text;
matched_date_keyword  text;
s_matched_biz_name_keyword text;
matched_date_display text := null; 
matched_bizname_display text :=null;
n_utilization_value numeric := null;
s_utilization_message text :=null;
s_utilization_voice_message text :=null;
s_query_id integer; 
eva_emoji text := ''; -- ':information_desk_person: '
s_insights_json_output text; -- this is to store the insights json from the build_insights_json_output 
s_sqlquery_total_cash text := ' select cast(round(sum(a.available_balance),0) as money) from plaidmanager_account a where a.account_sub_type = ''checking'' and a.deleted_at is null and ';
s_sqlquery_snapshot_where text := ' user_id = ';
s_sqlquery_total_outstanding_balance text := ' select cast(round(sum(a.current_balance),0) as money) from plaidmanager_account a where a.account_sub_type = ''credit card'' and a.deleted_at is null and '; 
s_sqlquery_utilization text := ' select concat(round(((sum(case a.current_balance WHEN null THEN 0 ELSE a.current_balance END) / sum(case a.balance_limit WHEN null THEN a.available_balance ELSE a.balance_limit END)) * 100),1), ''%'') from plaidmanager_account a , plaidmanager_item item, plaidmanager_institutionmaster i  ';     
s_sqlwhere text;   
s_total_cash text; 
s_total_outstanding_balance text; 
s_utilization_value text;
s_sentiment text;

--Context Retaining changes
s_pattern_name text := null;
q_intent_name text :=NULL;
h_intent_name text :=NULL;
h_category_levels_to_check text;
h_category_level0 text; 
h_category_level1 text;
h_category_level2 text; 
h_txn_biz_name text; 
h_from_date text; 
h_to_date text; 
h_matched_institution_name text;
h_amount text;
h_plaid_account_name text;
h_plaid_account_subtype text;
h_ending_number text;

BEGIN  
    IF (p_user_id IS NULL) OR (p_user_query_text IS NULL) THEN 
        display_message := 'Sorry, I am having some trouble processing your request. Please try again after some time.';    
        display_screen_name := 'results_screen'; 
        display_type :='message';
    ELSE 

        BEGIN 
            select first_name from users_user where id = p_user_id into s_user_nickname; 
            RAISE INFO 'User nickname: <%>', s_user_nickname;
        EXCEPTION WHEN OTHERS THEN 
            s_user_nickname := NULL;  
            --RAISE INFO 'inside user nickname exception : <%>', s_user_nickname;
        END; 

        BEGIN 
            SELECT * from get_user_sentiment_from_query(p_user_id, p_user_query_text, p_query_mode, p_query_source) INTO s_sentiment;
            RAISE INFO 'user sentiment <%>', s_sentiment;
        EXCEPTION WHEN OTHERS THEN 
            s_sentiment := NULL;  
        END;
        --Context Retaining changes
        BEGIN 
            select q.intent_name from users_userqueryhistory q where q.id = (select max(query.id) from users_userqueryhistory query where query.user_id = p_user_id and query.intent_name <> '') INTO h_intent_name;
            RAISE INFO 'h_intent_name <%>', h_intent_name;

            FOR r IN SELECT * FROM configure_intent where is_active = TRUE order by id asc LOOP
              IF (((regexp_matches(concat(' ', lower(p_user_query_text), ' '), lower(r.keywords), 'g'))[1]) IS NOT NULL) THEN
                q_intent_name := r.code;
                RAISE INFO 'q_intent_name <%>', q_intent_name;
                EXIT;
              END IF;
            END LOOP;
        EXCEPTION WHEN OTHERS THEN 
            s_sentiment := NULL;  
            RAISE INFO 'Error Name:%',SQLERRM;
            RAISE INFO 'Error State:%', SQLSTATE;
        END;

        FOR r IN SELECT * FROM configure_intent where is_active = TRUE order by id asc LOOP
            s_pattern_name := ((regexp_matches(concat(' ', lower(p_user_query_text), ' '), lower(r.keywords), 'g'))[1]); 
            IF (s_pattern_name IS NOT NULL) OR (h_intent_name IS NOT NULL AND q_intent_name IS NULL AND h_intent_name = r.code) THEN
            --IF ((regexp_matches(concat(' ', lower(p_user_query_text), ' '), lower(r.keywords), 'g'))[1]) IS NOT NULL THEN
                
                intent_name := r.code; 
                display_screen_name := r.display_screen_name; 
                display_type := r.display_type;

                IF r.is_date_check THEN  
                 SELECT * from get_date_from_user_query(p_user_query_text) INTO from_date, to_date, matched_date_keyword;
                 IF matched_date_keyword IS NOT NULL THEN 
                  --matched_date_display := concat (' between ', to_char(from_date::date, 'DD Month YYYY'), ' and ', to_char(to_date::date, 'DD Month YYYY'), ' ');
                  matched_date_display := concat (' during ' , matched_date_keyword); 
                 ELSE 
                  matched_date_display := concat('', '');
                 END IF; 
                END IF;   
                IF r.is_account_name_check THEN    
                    SELECT * from get_account_name_from_user_query(p_user_query_text) INTO plaid_account_name, matched_account_name_keyword ;          
                END IF;   
                IF r.is_charge_category_check THEN
                    select * from get_charge_category_from_user_query(p_user_query_text) into category_levels_to_check,category_level0,category_level1,category_level2,matched_category_keyword ;
                END IF;   
            /*    IF r.card_reco_category_check THEN 
                    select * from get_card_reco_category_from_user_query(p_user_query_text) into category_levels_to_check,category_level0,category_level1,category_level2,matched_category_keyword ;
                END IF; 
                */
                --RAISE INFO 'Txn biz name check: <%>', r.is_transaction_biz_name_check;
                IF r.is_transaction_biz_name_check THEN
                    select * from get_txn_biz_name_from_user_query(p_user_query_text,p_user_id) into txn_biz_name;
                END IF;  
                --RAISE INFO 'general_biz_name_check : <%>', r.is_general_biz_name_check ;   
                IF r.is_general_biz_name_check THEN 
                  IF txn_biz_name IS NULL THEN
                    select * from get_biz_name_from_user_query(p_user_query_text) into txn_biz_name, s_matched_biz_name_keyword;
                  ELSE 
                  END IF;   
                END IF;
                IF txn_biz_name IS NOT NULL THEN 
                  matched_bizname_display := concat (' at ', initcap(txn_biz_name) ,' ');
                 ELSE 
                  matched_bizname_display := concat('', '');
                 END IF;                    
                IF r.is_amount_check THEN
                 select * from get_amount_from_user_query(p_user_query_text) into s_amount;
                END IF; 
                IF r.is_account_ending_check THEN 
                    select * from get_account_ending_number_from_user_query(p_user_query_text, p_user_id) into ending_number;
                END IF; 
                IF r.is_account_subtype_check THEN 
                    select * from get_account_subtype_from_user_query(p_user_query_text) into plaid_account_subtype;
                END IF; 
                IF r.is_institution_type_check THEN 
                    select * from get_institution_id_from_user_query(p_user_query_text) into plaid_institution_id, matched_institution_name;
                END IF; 
                --IF r.card_name_check THEN
                    --call get_card_from_query
                --END IF; 


                RAISE INFO 'Intent Name: <%>', intent_name;
                RAISE INFO 'Intent Desc: <%>', intent_desc;
                RAISE INFO 'Intent Type: <%>', intent_type;
                RAISE INFO 'display screen: <%>', display_screen_name;
                RAISE INFO 'display type: <%>', display_type;
                RAISE INFO 'From date : <%>', from_date;
                RAISE INFO 'To date : <%>', to_date; 
                RAISE INFO 'Amount: <%>', s_amount; 
                RAISE INFO 'Plaid Account Name: <%>', plaid_account_name; 
                RAISE INFO 'Plaid Account sub type: <%>', plaid_account_subtype; 
                RAISE INFO 'Plaid Account ending: <%>', ending_number;
                RAISE INFO 'Plaid Institution Id: <%>', plaid_institution_id;
                RAISE INFO 'Plaid Institution Name: <%>', matched_institution_name;
                RAISE INFO 'category level: <%>', category_levels_to_check;
                RAISE INFO 'category 0: <%>', category_level0;
                RAISE INFO 'category1: <%>', category_level1; 
                RAISE INFO 'category2: <%>', category_level2;
                RAISE INFO 'txn biz name: <%>', txn_biz_name; 
                RAISE INFO 'account ending number: <%>', ending_number;

                IF (q_intent_name IS NULL) THEN

                  IF category_levels_to_check IS NULL AND category_levels_to_check IS NULL AND category_level0 IS NULL AND category_level1 IS NULL AND category_level2 IS NULL AND txn_biz_name IS NULL AND from_date IS NULL AND to_date IS NULL AND matched_institution_name IS NULL AND s_amount IS NULL AND plaid_account_name IS NULL AND plaid_account_subtype IS NULL AND ending_number IS NULL THEN
                    RAISE INFO 'NOT A VALID FOLLOW UP QUESTION OR QUESTION -> SEND ERROR MESSAGE';

                    IF (s_user_nickname IS NOT NULL) THEN 
                      display_message:= concat('Sorry ', s_user_nickname, ', I was unable to get that information for you. Here are some other things that I can help you with');
                      voice_message := display_message;
                    ELSE
                      display_message := 'Sorry, I was unable to gather the information for your request.';
                      voice_message := display_message;
                    END IF; 

                      display_screen_name := 'results_screen'; 
                      display_type :='message_error';
                      intent_name := NULL;
                      EXIT;
                  ELSE 

                    select q.intent_name, q.category_levels_to_check, q.category_level0, q.category_level1, q.category_level2, q.txn_biz_name, q.from_date, q.to_date, q.matched_institution_name, q.amount, q.plaid_account_name, q.plaid_account_subtype, q.ending_number from users_userqueryhistory q where q.id = (select max(query.id) from users_userqueryhistory query where query.user_id = p_user_id and query.intent_name <> '') INTO h_intent_name, h_category_levels_to_check, h_category_level0, h_category_level1, h_category_level2, h_txn_biz_name, h_from_date, h_to_date, h_matched_institution_name, h_amount, h_plaid_account_name, h_plaid_account_subtype, h_ending_number;
                  

                    IF s_amount IS NULL THEN 
                      s_amount := h_amount;
                    END IF; 
                    IF plaid_account_name IS NULL THEN 
                      plaid_account_name := h_plaid_account_name;
                    END IF; 
                    IF plaid_account_subtype IS NULL THEN 
                      plaid_account_subtype := h_plaid_account_subtype;
                    ELSIF plaid_account_subtype IS NOT NULL THEN 
                      h_ending_number :=NULL;
                    END IF; 
                    IF ending_number IS NULL THEN 
                      ending_number := h_ending_number;
                    ELSIF ending_number IS NOT NULL THEN 
                      plaid_account_subtype := NULL;
                    END IF; 
                    IF category_levels_to_check IS NULL THEN 
                      category_levels_to_check := h_category_levels_to_check;
                    END IF; 
                    IF category_level0 IS NULL THEN 
                      category_level0 := h_category_level0;
                    ELSIF category_level0 IS NOT NULL THEN
                      h_txn_biz_name := NULL;
                    END IF; 
                    IF category_level1 IS NULL THEN 
                      category_level1 := h_category_level1;
                    END IF; 
                    IF category_level2 IS NULL THEN 
                      category_level2 := h_category_level2;
                    END IF; 
                    IF from_date IS NULL THEN 
                      from_date := h_from_date;
                    END IF; 
                    IF to_date IS NULL THEN 
                      to_date := h_to_date;
                    END IF; 
                    IF txn_biz_name IS NULL THEN 
                      txn_biz_name := h_txn_biz_name;
                    ELSIF txn_biz_name IS NOT NULL THEN
                      category_level0 := NULL;
                      category_level1 := NULL;
                      category_level2 := NULL;
                      category_levels_to_check := NULL;
                    END IF; 
                    IF matched_institution_name IS NULL THEN 
                      matched_institution_name := h_matched_institution_name;
                    END IF; 

                    RAISE INFO 'Updated From date : <%>', from_date;
                    RAISE INFO 'UpdatedTo date : <%>', to_date; 
                    RAISE INFO 'Updated Plaid Institution Name: <%>', matched_institution_name;
                    RAISE INFO 'Updated category level: <%>', category_levels_to_check;
                    RAISE INFO 'Updated category 0: <%>', category_level0;
                    RAISE INFO 'Updated category1: <%>', category_level1; 
                    RAISE INFO 'Updated category2: <%>', category_level2;
                    RAISE INFO 'Updated txn biz name: <%>', txn_biz_name; 
                  END IF;
                END IF;

                --consolidate all parameters and call the right functions

                CASE lower(intent_name)
                    WHEN 'welcome_message' THEN 
                      IF (s_user_nickname IS NOT NULL) THEN 
                          display_message:= concat('Hey  ', s_user_nickname, ', hows it going? How can I help you today?');
                      ELSE 
                          display_message:= 'Hey! Hows it going? How can I help you today?';
                      END IF;  
                    WHEN 'available_balance' THEN  
                      BEGIN
                          select * from get_available_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the available balance for your criteria.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the available balance for your criteria.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your available balance is ', display_value);
                              voice_message:= concat ('Your available balance is ', display_value);
                              display_type := 'accounts_green';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END; 
                    WHEN 'daily_briefing' THEN  
                      BEGIN
                        s_sqlquery_total_cash := concat(s_sqlquery_total_cash, s_sqlquery_snapshot_where, p_user_id); 
                        BEGIN
                          EXECUTE s_sqlquery_total_cash into s_total_cash; 
                          IF s_total_cash IS NULL THEN 
                            s_total_cash :='Unavailable';
                          END IF; 

                        EXCEPTION WHEN OTHERS THEN
                            s_total_cash :='Unavailable';
                        END;
                        
                        s_sqlquery_total_outstanding_balance := concat(s_sqlquery_total_outstanding_balance, s_sqlquery_snapshot_where, p_user_id); 
                        BEGIN
                          EXECUTE s_sqlquery_total_outstanding_balance into s_total_outstanding_balance; 
                          IF s_total_outstanding_balance IS NULL THEN 
                            s_total_outstanding_balance :='Unavailable';
                          END IF; 

                        EXCEPTION WHEN OTHERS THEN
                            s_total_outstanding_balance :='Unavailable';
                        END;

                        s_sqlwhere := concat(' where 1 = 1 and lower(a.account_sub_type) in ( ''credit card'') and a.plaidmanager_item_id = item.id and item.institute_id = i.id and a.deleted_at is null and a.user_id =   ', p_user_id );  

                        s_sqlquery_utilization := concat(s_sqlquery_utilization, s_sqlwhere); 
                        BEGIN
                          EXECUTE s_sqlquery_utilization into s_utilization_value; 
                          IF s_utilization_value IS NULL THEN 
                            s_utilization_value :='Unavailable';
                          END IF; 

                        EXCEPTION WHEN OTHERS THEN
                            s_utilization_value :='Unavailable';
                        END;

                        select * from get_available_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;

                        display_message:= concat ( s_user_nickname, ', your total cash is ', s_total_cash, ', your total payoff outstanding is ', s_total_outstanding_balance, ', and your overall credit usage is at ', s_utilization_value, '.');
                        voice_message:= display_message;
                        display_type := 'accounts_green';
                          
                        IF (account_data_as_json IS NULL) and (s_total_cash = 'Unavailable') and (s_total_outstanding_balance = 'Unavailable') and  (s_utilization_value = 'Unavailable') THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the daily briefing information for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the daily briefing information for you', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                        END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END;

                    WHEN 'credit_card_listing' THEN  
                      BEGIN
                          select * from get_credit_card_listing(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the credit card listing for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the credit card listing for you.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is a listing of your credit cards and the associated available balance for each card');
                              voice_message:= concat (eva_emoji, 'Here is a listing of your credit cards and the associated available balance for each card');
                              display_type := 'accounts_green';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END;     

                      WHEN 'improve_credit_score' THEN 
                        BEGIN 
                          display_type := 'accounts_porange';
                          select * from get_improve_credit_score (p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_message, display_notes, voice_message, account_data_as_json;
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                          -- voice_message := display_message; 
                          display_message := concat (eva_emoji,display_message);
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END; 
                      WHEN 'high_yield_savings' THEN 
                        BEGIN 
                          display_type := 'message_image';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'Saving money can be a real challenge but here is how you can earn a high interest rate on your money.';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'how_long_switch_to_nbs_takes' THEN 
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat (s_user_nickname, ', the switch process normally takes less than 7 days. Here are some information that will help you make the switch. ', null); 
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 
                          display_notes :=concat( ':point_right: More information available  <a href=\"https://www.nationwide.co.uk/products/current-accounts/our-current-accounts/switch#how-can-i-switch\">here</a><br><br> :point_right: Thinking about switching? Switching your bank or building society current account means you open a new account and your old account is closed. All your existing payments are moved from your old account to your new current account.', null);

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'nbs_switching_process' THEN 
                        BEGIN 
                          display_type := 'message_image';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'Here is how the switch process will happen. Tap on the image to get more details';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'switch_to_nbs' THEN 
                        BEGIN 
                          display_type := 'message_form';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'We are glad you are switching to Nationwide. Please complete the following information to get started.';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'credit_protection' THEN 
                        BEGIN 
                          display_type := 'credit_protection';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := 'I am glad you took advantage of this, especially at this time. We can help you activate the service since this works like your insurance on your credit card. Would you like to avail this?';
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'lost_job_repayment_options' THEN 
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( s_user_nickname, ', I am sorry to hear that you lost your job :disappointed: and are going through some tough times right now. Let us see if there is anything I can do to help you out. In the meantime, can you please verify your address? ', null); 
                          voice_message := concat ( s_user_nickname, ', I am sorry to hear that you lost your job and are going through some tough times right now. Let us see if there is anything I can do to help you out. In the meantime, can you please verify your address?', null);
                          --RAISE INFO 'resulting display notes : <%>', display_notes;

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'address_verification' THEN 
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Thanks for the verification! Here are some offers that you can leverage: ', null); 
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 
                          display_notes :=concat( ':point_right: Credit Protection: <a href=\"https://www.google.com\">Good news! Looks like you are enrolled and eligible to avail this offer</a><br><br> :point_right: LSFW: <a href=\"https://www.google.com\">Tap here to know more about this offer. Just say LSFW to avail this offer</a><br><br> :point_right: Re age: <a href=\"https://www.google.com\">Tap here to know more about this offer.</a><br><br>:point_right: Date Out: <a href=\"https://www.google.com\">Tap here to know more about this offer.</a><br><br>', null);
                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'make_a_payment' THEN 
                        BEGIN 
                          display_type := 'message';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( s_user_nickname, ', glad to know you would like to make a payment :thumbsup:. Before we get started, can you please confirm the last four digits of your Social Security number?', null); 
                          voice_message := concat ( s_user_nickname, ', glad to know you would like to make a payment. Before we get started, can you please confirm the last four digits of your Social Security number?', null); 
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'social_security' THEN 
                        BEGIN 
                          display_type := 'message';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Thanks ', s_user_nickname, '! How much would you like to pay towards your payment?', null); 
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'payment_200' THEN
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Thanks ', s_user_nickname, '! May we suggest you pay $240 as this is your minimum due at this time :blush:? ', null); 
                          voice_message := concat ( 'Thanks ', s_user_nickname, '! May we suggest you pay $240 as this is your minimum due at this time? ', null); 
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'payment_240' THEN 
                        BEGIN 
                          display_type := 'message_notes';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Great! How would you like to make the payment? Here are some options for you', null); 
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 
                          display_notes :=concat( ':point_right: Debit Card  <a href=\"https://www.google.com\">Tap here to enter your Debit Card details</a><br><br> :point_right: Checking Account: Just Say Checking Account and the payment will be processed automatically from your connected Checking Account', null);
                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'payment_with_checking_account' THEN 
                        BEGIN 
                          display_type := 'message';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ( 'Nice job ', s_user_nickname, ':clap::clap::clap:! You are all set now! Your payment will be processed in 1-2 days. Thanks for your time.', null); 
                          voice_message := concat ( 'Nice job ', s_user_nickname, '! You are all set now! Your payment will be processed in 1-2 days. Thanks for your time.', null); 
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 
                
                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'credit_lsfw' THEN 
                        BEGIN 
                          display_type := 'credit_lsfw';
                          -- RAISE INFO 'resulting message : <%>', display_message; 
                           
                          display_message := concat ('I have great news for you ', s_user_nickname , '. As of the moment, we can see that you have an offer on the account to clear up your balance and save money. Instead of paying for the full balance, we just need to make a payment of $214.89 by 20th December and we are all set.');
                          voice_message := display_message;
                          --RAISE INFO 'resulting display notes : <%>', display_notes; 

                          EXCEPTION WHEN OTHERS THEN
                                  display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                  voice_message := display_message;
                                  display_type := 'message';
                                  p_query_status := 'incomplete';
                      END;
                      WHEN 'view_utilization' THEN 
                        BEGIN
                          select * from get_utilization(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          IF (display_value is null) OR (display_value = '%') THEN 
                              n_utilization_value :=' currently unavailable '; 
                          ELSE 
                              n_utilization_value := to_number(display_value, '99.9'); 
                              IF n_utilization_value <=9 THEN 
                                  s_utilization_message := ' Excellent job on keeping your utilization under control :clap::clap::clap:'; 
                                  s_utilization_voice_message := ' Excellent job on keeping your utilization under control'; 
                              ELSIF n_utilization_value BETWEEN 9 AND 29 THEN 
                                  s_utilization_message := ' Very good job on keeping your utilization low. :clap::clap:'; 
                                  s_utilization_voice_message := ' Very good job on keeping your utilization low'; 
                              ELSIF n_utilization_value BETWEEN 29 AND 49 THEN
                                  s_utilization_message := ' Good job on keeping your utilization less than 50%.:clap:'; 
                                  s_utilization_voice_message := ' Good job on keeping your utilization less than 50%'; 
                              ELSIF n_utilization_value BETWEEN 49 AND 75 THEN 
                                  s_utilization_message := ' Fair job on keeping your utilization less than 75%.'; 
                                  s_utilization_voice_message := ' Fair job on keeping your utilization less than 75%.'; 

                              ELSIF n_utilization_value >75 THEN 
                                  s_utilization_message := ' Watch out, you are approaching your maximum utilization :exclamation:'; 
                                  s_utilization_voice_message := ' Watch out, you are approaching your maximum utilization'; 

                              ELSE 
                                  s_utilization_message :=NULL;
                              END IF;     
                          END IF; 
                          --RAISE INFO 'resulting utilization accounts json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message; 
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your current utilization is ', display_value, '.', s_utilization_message);
                              voice_message:= concat ('Your current utilization is ', display_value, '.', s_utilization_voice_message);
                              --voice_message := display_message;
                              IF n_utilization_value <= 35 THEN 
                                display_type := 'accounts_ured';
                              ELSIF n_utilization_value BETWEEN 35 and 70 THEN 
                                display_type := 'accounts_ured';
                              ELSIF n_utilization_value BETWEEN 70 and 100 THEN
                                display_type := 'accounts_ured';
                              ELSE 
                                display_type := 'accounts_ured';
                              END IF;
                          END IF; 
                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message; 
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END; 
                     WHEN 'credit_limit' THEN
                      BEGIN
                          select * from get_credit_limit(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting credit limit account json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the credit limit for your criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji,'The credit limit for your criteria is ', display_value);
                              voice_message := concat ('The credit limit for your criteria is ', display_value);
                              display_type := 'accounts_green';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END; 
                    WHEN 'credit_card_payments' THEN 
                      BEGIN     
                          select * from get_credit_card_payments(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have made credit card payments of ', display_value, '. Here are the associated payment transactions.');
                              voice_message := concat ('You have made credit card payments of ', display_value, '. Here are the associated payment transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have made credit card payments of ', display_value);
                              voice_message := concat ( 'You have made credit card payments of ', display_value);
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no credit card payments for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;


                      WHEN 'debit_transactions' THEN 
                      BEGIN     
                          select * from get_debit_transactions(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('Here are your recent debit transactions.');
                              voice_message := concat ('Here are your recent debit transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('Here are your recent debit transactions.');
                              voice_message := concat ('Here are your recent debit transactions.');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no debit transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END; 
                     WHEN 'how_can_i_save_money' THEN  

                      BEGIN 
                        display_type := 'message_notes';
                        select * from get_how_can_i_save_money(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_message, display_notes, voice_message;
                        voice_message := display_message;
                        display_message := concat(eva_emoji, display_message); 
                        --RAISE INFO 'resulting message : <%>', display_message; 
                        --RAISE INFO 'resulting display notes : <%>', display_notes; 

                        EXCEPTION WHEN OTHERS THEN
                                display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                                voice_message := display_message;
                                display_type := 'message';
                                p_query_status := 'incomplete';
                      END;     
                     WHEN 'view_transactions' THEN 
                      BEGIN 

                          select * from get_transactions_json(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there werent any transactions for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here are your transactions ', matched_bizname_display, matched_date_display , null);
                              voice_message := concat (eva_emoji, 'Here are your transactions ', matched_bizname_display, matched_date_display , null);
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              display_type := 'message';
                              voice_message := display_message;
                              p_query_status := 'incomplete';
                      END;  

                      WHEN 'view_credit_card_transactions' THEN 
                        BEGIN     
                          select * from get_credit_card_transactions(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there werent any credit card transactions for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_type := 'message_transaction';
                              display_message:= concat (eva_emoji, 'Here are your credit card transaction details..', null);
                              voice_message := concat ('Here are your credit card transaction details..', null);
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              display_type := 'message';
                              voice_message := display_message;
                              p_query_status := 'incomplete';
                      END;  
                      WHEN 'card_reco' THEN  
                        BEGIN
                          --RAISE INFO 'inside card reco : <%>', p_user_id; 
                
                          display_message:= concat('Here are your card recommendations');   
                          voice_message :=  concat('Here are your card recommendations');                  
                          display_type :='card_recommendation'; 
                          --select * from insert_into_user_query_tear_down_v1 ( p_chat_reference_id, p_user_id , p_user_query_text, p_query_source , p_query_mode , intent_name , p_query_status, display_type, display_message ,display_value ,display_notes , transaction_output_as_json , graph_data_as_json , results_json) into s_query_id; 
                          select * from insert_into_user_query_tear_down_v1 (p_user_id , p_user_query_text, p_query_source , p_query_mode , intent_name , p_query_status, display_type, display_message ,display_value ,display_notes , transaction_output_as_json , graph_data_as_json , results_json, category_levels_to_check, category_level0, category_level1, category_level2, txn_biz_name, from_date, to_date, matched_institution_name, s_amount, plaid_account_name, plaid_account_subtype, ending_number) into s_query_id;  

                          RAISE INFO ' insert_into_user_query_tear_down returns the query id : <%>', s_query_id; 

                          IF s_query_id is not null THEN 
                              select * from get_card_recommendations (s_query_id,p_user_id, p_user_query_text, s_amount ) into card_reco_data_as_json;
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          s_query_id :=null; 
                      END;   
                    WHEN 'how_much_interest_have_i_paid' THEN 
                      BEGIN     
                          select * from get_interest_paid(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              IF lower(s_sentiment) = 'angry' THEN 
                                display_message:= concat (s_user_nickname, ', completely understand your concern about the interest charges for ', display_value, '. However these are charges levied by the bank towards your outstanding balance. Paying off more on the outstanding balance will bring down penalties and interest charges.');
                                voice_message:= concat (s_user_nickname, ', completely understand your concern about the interest charges for ', display_value, '. However these are charges levied by the bank towards your outstanding balance.');
                              ELSE 
                                display_message:= concat (eva_emoji, 'You have paid ', display_value, ' as interest. Here are the associated charges.');
                                voice_message := concat ('You have paid ', display_value, ' as interest. Here are the associated charges.');
                              END IF; 

                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'You have paid ', display_value, ' as interest. Here are the associated charges.');
                              voice_message := concat ('You have paid ', display_value, ' as interest. Here are the associated charges.');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no transactions for your criteria.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', there were no transactions for your criteria.', null); 
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END; 
                    WHEN 'last_thing_bought' THEN 
                      BEGIN     
                          select * from get_last_thing_bought(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no transactions for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here are your last bought transactions', null);
                              voice_message := concat ( 'Here are your last bought transactions', null);
                              display_type := 'message_transaction';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;   
                    WHEN 'last_visit' THEN 
                      BEGIN     
                          select * from get_last_visit(p_user_query_text, p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              voice_message := concat ('Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              voice_message := concat ('Your last visit was ', display_value, '. Here are a few recent transactions for your reference. ');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there werent any transactions for that criteria.', null);
                              voice_message := display_message; 
                              p_query_status := 'incomplete';
                              display_type := 'message';  
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;                   
                             
                    WHEN 'monthly_average_spending' THEN 
                      BEGIN
                          select * from get_monthly_average_spending(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is your monthly average spend information ');
                              voice_message := concat ( 'Here is your monthly average spend information ');
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END; 
 
                   WHEN 'yearly_average_spending' THEN 
                      BEGIN
                          select * from get_yearly_average_spending(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is your yearly average spend information ');
                              voice_message := concat ( 'Here is your yearly average spend information ');
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END; 
                   WHEN 'weekly_average_spending' THEN 
                      BEGIN
                          select * from get_weekly_average_spending(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here is your weekly average spend information ');
                              voice_message := concat ( 'Here is your weekly average spend information ');
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END;
                    WHEN 'future_financial_status' THEN 
                      BEGIN
                          select * from get_future_financial_status(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get that information for you.', null);
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (s_user_nickname, ', given your current income, and a saving potential of 20%, this will be your financial projection for the future.');
                              voice_message := display_message;
                              display_type := 'message_bar';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get that information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END;   
                    WHEN 'credit_card_payment_due' THEN 
                      BEGIN     
                          select * from get_next_payment_date(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          IF display_value is NOT NULL THEN 
                          --select (case when date(display_value) = date(now()) THEN 'Today' ELSE

                               display_value := concat(substr(rtrim(initcap(to_char(date(display_value), 'day'))),1, 9),', ', date_part('day', date(display_value)),' ', substr(rtrim(to_char(date(display_value), 'Month')),1,9),' ', EXTRACT(YEAR FROM date(display_value)));  
                          END IF; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting new display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Based on your past payments, it appears your payment due is ', display_value, '. Here are some of your most recent payments.');
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'Based on your past payments, it appears your next payment due is ', display_value);
                              display_type := 'message';
                              voice_message := display_message;
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 
                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;                       
                    WHEN 'outstanding_balance' THEN 
                      BEGIN
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting outstanding balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to get the outstanding balance information for you.', null); 
                              display_type := 'message';
                              p_query_status := 'incomplete'; 
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your current outstanding balance is ', display_value);
                              voice_message := concat ('Your current outstanding balance is ', display_value);
                              display_type := 'accounts_ored';
                          END IF; 
                          
                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END;

                    WHEN 'transfer_from_current_savings' THEN  
                      BEGIN
                          display_screen_name := intent_name;
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          display_value := s_amount;
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE
                            IF p_query_language = 'en' THEN 
                                display_screen_name := intent_name;
                                display_message:= concat ('Are you sure you would like to initiate the transfer', '', '?');
                                voice_message:= concat ('Are you sure you would like to initiate the transfer', '', '?');
                            ELSE 
                                display_message:= concat ('Are you sure you would like to initiate the transfer', '', '?');
                                voice_message:= concat ('Are you sure you would like to initiate the transfer', '', '?');  
                              END IF;
                              display_type := 'message';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END;  
                    WHEN 'bill_payment' THEN  
                      BEGIN
                          display_screen_name := intent_name;
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          display_value := s_amount;
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE
                            IF p_query_language = 'en' THEN 
                                display_screen_name := intent_name;
                                display_message:= concat ('Are you sure you would like to initiate the bill payment', '', '?');
                                voice_message:= concat ('Are you sure you would like to initiate the bill payment', '', '?');
                            ELSE 
                                display_message:= concat ('Are you sure you would like to initiate the bill payment', '', '?');
                                voice_message:= concat ('Are you sure you would like to initiate the bill payment', '', '?');  
                              END IF;
                              display_type := 'message';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END;    
                    WHEN 'schedule_bill_payments' THEN  
                      BEGIN
                          display_screen_name := intent_name;
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting available balance json : <%>', account_data_as_json; 
                          display_value := s_amount;
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null); 
                              voice_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for you.', null);
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE
                            IF p_query_language = 'en' THEN 
                                display_screen_name := intent_name;
                                display_message:= concat ('Are you sure you would like to schedule the bill payment', '', '?');
                                voice_message:= concat ('Are you sure you would like to schedule the bill payment', '', '?');
                            ELSE 
                                display_message:= concat ('Are you sure you would like to schedule the bill payment', '', '?');
                                voice_message:= concat ('Are you sure you would like to schedule the bill payment', '', '?');  
                              END IF;
                              display_type := 'message';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message_error';
                          p_query_status := 'incomplete';

                      END;   
                    WHEN 'purchasing_transactions' THEN 
                      BEGIN     
                          select * from get_purchasing_transactions(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I could not find any related transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSIF (matched_date_keyword = 'recent') or  (matched_date_keyword = 'recently') THEN 
                              display_message:= concat (eva_emoji,'Here are your recent purchases ', matched_bizname_display);
                              voice_message := concat ('Here are your recent purchases ', matched_bizname_display);
                              display_type := 'message_transaction';

                          ELSE 
                              display_message:= concat (eva_emoji,'Here are the purchasing transactions for your criteria', null);
                              voice_message := concat ('Here are the purchasing transactions for your criteria..', null);
                              display_type := 'message_transaction';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;    
                    WHEN 'recurring_charges' THEN 
                      BEGIN     
                          select * from get_recurring_charges(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no recurring charges for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji,'Here are your recurring charges information', null);
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null);
                              voice_message := display_message; 
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;   
                    WHEN 'spend_by_category' THEN 
                      BEGIN
                          select * from get_spend_by_category(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, graph_data_as_json;
                          --RAISE INFO 'resulting graph json : <%>', graph_data_as_json; 
                          IF graph_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the spend category information.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji,'Here is your spend by category information');
                              voice_message := concat ('Here is your spend by category information');
                              display_type := 'message_piechart';
                              display_notes := display_value;
                          END IF;
                       EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';

                      END;
                    WHEN 'spend_check' THEN 
                      BEGIN     
                          select * from get_spend_check(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji,'You have spent ', display_value, matched_bizname_display , matched_date_display, '. Here are the associated transactions.');
                              voice_message := concat (eva_emoji,'You have spent ', display_value, matched_bizname_display , matched_date_display, '. Here are the associated transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat (eva_emoji, 'You have spent ', display_value);
                              voice_message := concat ( 'You have spent ', display_value);
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I could not find any ', matched_bizname_display, ' related transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;
                    WHEN 'atm_related_transactions' THEN 
                      BEGIN     
                          select * from get_atm_withdrawals(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 
                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have withdrawn ', display_value, ' from the ATM. Here are the transactions.');
                              voice_message := concat ('You have withdrawn ', display_value, ' from the ATM. Here are the transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have withdrawn ', display_value, ' from the ATM.');
                              voice_message := concat ('You have withdrawn ', display_value, ' from the ATM.');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no ATM transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;   
                    WHEN 'user_earnings' THEN 
                      BEGIN     
                          select * from get_user_earnings(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 
                          --RAISE INFO 'resulting transaction_output_as_json : <%>', transaction_output_as_json; 
                          --RAISE INFO 'resulting display value : <%>', display_value; 

                          IF (transaction_output_as_json IS NOT NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have a total earning of ', display_value, '. Here are the related transactions.');
                              voice_message := concat ('You have a total earning of ', display_value, '. Here are the related transactions.');
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS NOT NULL) AND (display_value is NULL) THEN 
                              display_message:= NULL;
                              voice_message := display_message;
                              display_type := 'message_transaction';
                          ELSIF (transaction_output_as_json IS  NULL) AND (display_value is NOT NULL) THEN 
                              display_message:= concat ('You have a total earning of ', display_value, '');
                              voice_message := concat ('You have a total earning of ', display_value, ' ');
                              display_type := 'message';
                          ELSE 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no relevant transactions for that condition.', null); 
                              voice_message := display_message;
                              display_type := 'message';  
                              p_query_status := 'incomplete';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to get the information for you.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END;  
                     WHEN 'subscriptions' THEN 
                      BEGIN
                          select * from get_subscription_charges(p_user_id, from_date, to_date,s_amount, plaid_account_name , plaid_account_subtype , plaid_institution_id , category_levels_to_check, category_level0, category_level1, category_level2, ending_number, txn_biz_name) into display_value, transaction_output_as_json; 

                          --RAISE INFO 'resulting txn json in main view transaction : <%>', transaction_output_as_json; 
                          IF transaction_output_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', there were no subscription related charges for that criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Here are your subscription related charges ', null);
                              voice_message := concat ('Here are your subscription related charges ', null);
                              display_type := 'message_transaction';
                          END IF;
                      EXCEPTION WHEN OTHERS THEN
                              display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                      END; 
                    WHEN 'net_worth' THEN 
                      BEGIN
                          select * from get_user_net_worth(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting net worth json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the net worth information.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your net worth is ', display_value, '. ');
                              voice_message := concat ( 'Your net worth is ', display_value, '. ');
                              display_type := 'message';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          voice_message := display_message;
                          display_type := 'message';
                          p_query_status := 'incomplete';
                      END;
                    WHEN 'account_balance' THEN 
                      BEGIN
                          select * from get_outstanding_balance(p_user_id,from_date,to_date,s_amount,plaid_account_name,plaid_account_subtype, plaid_institution_id,category_levels_to_check,category_level0,category_level1,category_level2,ending_number,txn_biz_name) into display_value, account_data_as_json;
                          --RAISE INFO 'resulting outstanding balance json : <%>', account_data_as_json; 
                          IF account_data_as_json IS NULL THEN 
                              display_message:= concat ('Sorry ', s_user_nickname, ', I am unable to retrieve the outstanding balance for your criteria.', null); 
                              voice_message := display_message;
                              display_type := 'message';
                              p_query_status := 'incomplete';
                          ELSE 
                              display_message:= concat (eva_emoji, 'Your account balance is ', display_value);
                              voice_message := concat ('Your account balance is ', display_value);
                              display_type := 'accounts_ored';
                          END IF; 

                      EXCEPTION WHEN OTHERS THEN 
                          display_message:= concat ('Sorry ', s_user_nickname, ', I was unable to gather the information for your request.', null); 
                          display_type := 'message';
                          voice_message := display_message;
                          p_query_status := 'incomplete';

                      END; 
                    WHEN 'user_insights' THEN
                      BEGIN
                        select * from get_user_insights (p_user_id) into snapshot_data_as_json, forecast_data_as_json, transactions_data_as_json, spend_by_category_data_as_json, utilization_data_as_json, improve_credit_data_as_json, card_recommendation_data_as_json, subscriptions_data_as_json, interest_paid_data_as_json;

                      EXCEPTION WHEN OTHERS THEN 

                      END;         
                    /*  

                    WHEN 'can_i_spend_scenario' THEN 
                      display_message:='all well for can_i_spend_scenario';                  
                   

                    WHEN 'how_am_i_doing' THEN 
                      display_message:='all well for how_am_i_doing';                    


                    */
                    ELSE
                      display_message:='Sorry, I was unable to gather the information for your request.'; 
                      display_type := 'message_error';

                END CASE;

                EXIT;  -- to make sure only the first intent gets executed..

            ELSE 
                --  do a run of all checks such as account sub type, category, txn_biz_type and account name type and call get_transactions 
                -- this will be a IF ELSE END IF for each condition . This will help in cases where user just says costco or starbucks or coffee or blue cash 
                IF (s_user_nickname IS NOT NULL) THEN 
                    display_message:= concat('Sorry ', s_user_nickname, ', I was unable to get that information for you. Here are some other things that I can help you with');
                    voice_message := display_message;

                ELSE
                    display_message := 'Sorry, I was unable to gather the information for your request.';
                    voice_message := display_message;
                END IF; 
                display_screen_name := 'results_screen'; 
                display_type :='message_error';
            END IF;

         END LOOP;
    END IF;

    BEGIN 
      IF (intent_name = 'card_reco') THEN 
        --not needed to insert again into user_query_tear_down as this was already done in the card_reco function
      ELSE 
        select * from insert_into_user_query_tear_down_v1 (p_user_id , p_user_query_text, p_query_source , p_query_mode , intent_name , p_query_status, display_type, display_message ,display_value ,display_notes , transaction_output_as_json , graph_data_as_json , results_json, category_levels_to_check, category_level0, category_level1, category_level2, txn_biz_name, from_date, to_date, matched_institution_name, s_amount, plaid_account_name, plaid_account_subtype, ending_number) into s_query_id;
        RAISE INFO 's_query_id ttt: <%>', s_query_id;
      END IF;
      
    EXCEPTION WHEN OTHERS THEN 
      s_query_id :=null;
    END;

    IF intent_name = 'user_insights' THEN 
      --RAISE INFO 'before building insights json: <%>', intent_name; 
      --RAISE INFO 's_query_id: <%>', s_query_id; 
      --RAISE INFO 'snapshot_data_as_json building insights json: <%>', snapshot_data_as_json; 
      --RAISE INFO 'forecast_data_as_json building insights json: <%>', forecast_data_as_json; 
      --RAISE INFO 'transactions_data_as_json building insights json: <%>', transactions_data_as_json; 
      --RAISE INFO 'spend_by_category_data_as_json building insights json: <%>', spend_by_category_data_as_json; 
      --RAISE INFO 'utilization_data_as_json building insights json: <%>', utilization_data_as_json; 
      --RAISE INFO 'improve_credit_data_as_json building insights json: <%>', improve_credit_data_as_json; 
      --RAISE INFO 'card_recommendation_data_as_json building insights json: <%>', card_recommendation_data_as_json; 
      --RAISE INFO 'subscriptions_data_as_json building insights json: <%>', subscriptions_data_as_json; 
      --RAISE INFO 'interest_paid_data_as_json building insights json: <%>', interest_paid_data_as_json; 

      BEGIN
        select * from build_insights_json_output (s_query_id, snapshot_data_as_json, transactions_data_as_json, subscriptions_data_as_json, spend_by_category_data_as_json, utilization_data_as_json, interest_paid_data_as_json, improve_credit_data_as_json, card_recommendation_data_as_json, forecast_data_as_json) into results_json;
        --RAISE INFO 'resulting build_insights_json text: <%>', s_insights_json_output; 
        --RAISE INFO 'resulting results_json text: <%>', results_json; 

      EXCEPTION WHEN OTHERS THEN 

        s_insights_json_output :='{"header": {"query_id": "exception"}}';
      END;
      --results_json := s_insights_json_output;
    ELSE
      select * from build_message_json_output_v1 (query_id, p_user_id, s_user_nickname, p_user_query_text, display_screen_name, display_type, display_message, voice_message, display_value, display_notes, p_chat_reference_id, transaction_output_as_json, graph_data_as_json , account_data_as_json, card_reco_data_as_json) into results_json; 
    END IF;   
    --RAISE INFO 'resulting json text: <%>', results_json; 
     /* -- if there are no matching intents based on the match up to the intent master, check to see if we can look for biz name or date or charge category keywords. 
            Based on that, call appropriate functions 
        IF (intent_name IS NULL THEN)
            ----RAISE INFO 'No matching intents..<%>', intent_name;
            -- check if the user mentioned about charge category check (like 'cafe last month' or 'coffee last month')
            -- check if user mentioned any business name ('coscto', 'starbucks last month')
            -- do a date check to see if user mentioned any dates or timeline ('starbucks last month', 'travel spend last month')
            -- now use the parameters to call a db function..(perhaps a default function that will get a summary of spend along with the transaction information )
            IF charge_category is not null and  d_from_date is not null and , d_to_date
        END IF; 
     */
  /* 
*/
EXCEPTION WHEN OTHERS THEN 
    
    IF (s_user_nickname IS NOT NULL) THEN 
        display_message:= concat('Sorry ', s_user_nickname, ', I am having some trouble processing your request. Please try again after some time.');
    ELSE
         display_message := 'Sorry, I am having some trouble processing your request. Please try again after some time.';
    END IF; 
    display_screen_name := 'results_screen'; 
    display_type :='message';

    select * from build_json_output (query_id, p_user_query_text, display_screen_name, display_type, display_message, voice_message, display_value, display_notes, transaction_output_as_json, graph_data_as_json , account_data_as_json, card_reco_data_as_json) into results_json; 

    --RAISE INFO 'resulting json text: <%>', results_json;    
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_user_query_results_v1(p_user_id IN integer, p_user_query_text IN text, p_query_mode IN text, p_query_source IN text, p_chat_reference_id IN text, OUT results_json text) OWNER TO evadev;

--******************--
--******************--

--Function Name: build_entity_values_json_output
-- Purpose: Function to build the entity values json output based on the different inputs
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION build_entity_values_json_output(user_query_text IN text, intent_name IN text, intent_desc IN text, display_type IN text, display_message IN text, voice_message IN text, from_date IN text, to_date IN text, s_amount IN text, plaid_account_subtype IN text, plaid_institution_id IN text, category_levels_to_check IN text, category_level0 IN text, category_level1 IN text, category_level2 IN text, txn_biz_name IN text, ending_number IN text, OUT json_output text)
AS $$
DECLARE 
s_record text; 
BEGIN

    json_output := concat ('{"user_query_text": "',user_query_text, '","intent_name": "',intent_name,'", "intent_desc": "',intent_desc,'","display_type": "', display_type, '","display_message": "', display_message, '","voice_message": "', voice_message, '","from_date": "', from_date, '","to_date": "', to_date, '","amount": "', s_amount , '","account_subtype": "', plaid_account_subtype , '","institution_id": "', plaid_institution_id , '","category_levels_to_check": "', category_levels_to_check, '","category_level0": "', category_level0, '","category_level1": "', category_level1, '","category_level2": "', category_level2, '","txn_biz_name": "', txn_biz_name, '"}');
    RAISE INFO 'Result inside build_json_output: <%>', json_output; 
EXCEPTION WHEN OTHERS THEN
    display_message :='Sorry :worried:, something went wrong, please try again.'; 
    voice_message := 'Sorry, something went wrong, please try again.'; 
    display_type := 'display_message';
    json_output := concat ('{"user_query_text": "',user_query_text, '","intent_name": "',intent_name,'", "intent_desc": "',intent_desc,'","display_type": "', display_type, '","display_message": "', display_message, '","voice_message": "', voice_message, '","from_date": "', from_date, '","to_date": "', to_date, '","amount": "', s_amount , '","account_subtype": "', plaid_account_subtype , '","institution_id": "', plaid_institution_id , '","category_levels_to_check": "', category_levels_to_check, '","category_level0": "', category_level0, '","category_level1": "', category_level1, '","category_level2": "', category_level2, '","txn_biz_name": "', txn_biz_name, '"}');

END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION build_entity_values_json_output(user_query_text IN text, intent_name IN text, intent_desc IN text, display_type IN text, display_message IN text, voice_message IN text, from_date IN text, to_date IN text, s_amount IN text, plaid_account_subtype IN text, plaid_institution_id IN text, category_levels_to_check IN text, category_level0 IN text, category_level1 IN text, category_level2 IN text, txn_biz_name IN text, ending_number IN text, OUT json_output text) OWNER TO evadev;


--******************--

--Function Name: get_entity_values
-- Purpose: Function to get entity values based on intent name 
-- version: 0.0 - baseline version

CREATE OR REPLACE FUNCTION get_entity_values(p_intent_name IN text, p_user_query_text IN text, OUT results_json text)
AS $$
DECLARE 
--global variables definition
r record; 
intent_name text :=NULL;
intent_desc text;
intent_type text;
display_type text;
query_id text; 
display_message text; 
voice_message text; 

from_date text; 
to_date text; 
s_amount text; 
matched_account_name_keyword text;

category_levels_to_check text; 
category_level0 text; 
category_level1 text;
category_level2 text; 
ending_number text; 
txn_biz_name text; 


s_user_nickname text := null; 
s_sentiment text;

matched_category_keyword text;
matched_date_keyword  text;
s_matched_biz_name_keyword text;
matched_date_display text := null; 
matched_bizname_display text :=null;

plaid_account_subtype text; 
plaid_institution_id text; 
matched_institution_name text;
s_matched_intent text;

BEGIN  
  RAISE INFO 'Just outside intent for loop <%>', intent_name; 
  FOR r IN SELECT * FROM configure_intent where code = p_intent_name LOOP
    RAISE INFO 'Just inside intent for loop <%>', r.code;
    
    IF r.code IS NOT NULL THEN
        RAISE INFO 'inside intent for loop <%>', s_sentiment;
        intent_name := r.code; 
        display_type := r.display_type;

        IF r.is_date_check THEN  
         RAISE INFO 'inside date check <%>', s_sentiment;
         SELECT * from get_date_from_user_query(p_user_query_text) INTO from_date, to_date, matched_date_keyword;
         IF matched_date_keyword IS NOT NULL THEN 
          --matched_date_display := concat (' between ', to_char(from_date::date, 'DD Month YYYY'), ' and ', to_char(to_date::date, 'DD Month YYYY'), ' ');
          matched_date_display := concat (' during ' , matched_date_keyword); 
         ELSE 
          matched_date_display := concat('', '');
         END IF; 
        END IF;   
        RAISE INFO 'matched_date_display: <%>', matched_date_display;

        IF r.is_charge_category_check THEN
            select * from get_charge_category_from_user_query(p_user_query_text) into category_levels_to_check,category_level0,category_level1,category_level2,matched_category_keyword ;
        END IF;   
        RAISE INFO 'Txn biz name check: <%>', r.is_transaction_biz_name_check;

        IF r.is_general_biz_name_check THEN 
          IF txn_biz_name IS NULL THEN
            select * from get_biz_name_from_user_query(p_user_query_text) into txn_biz_name, s_matched_biz_name_keyword;
          ELSE 
          END IF;   
        END IF;
        RAISE INFO 'txn_biz_name : <%>', txn_biz_name ;   

        IF r.is_amount_check THEN
         select * from get_amount_from_user_query(p_user_query_text) into s_amount;
        END IF; 
        RAISE INFO 's_amount : <%>', s_amount ;

        IF r.is_account_subtype_check THEN 
            select * from get_account_subtype_from_user_query(p_user_query_text) into plaid_account_subtype;
        END IF; 

        IF r.is_institution_type_check THEN 
            select * from get_institution_id_from_user_query(p_user_query_text) into plaid_institution_id, matched_institution_name;
        END IF; 


        RAISE INFO 'Intent Name: <%>', intent_name;
        RAISE INFO 'Intent Desc: <%>', intent_desc; 
        RAISE INFO 'Intent Type: <%>', intent_type; 
        RAISE INFO 'display type: <%>', display_type;
        RAISE INFO 'From date : <%>', from_date;
        RAISE INFO 'To date : <%>', to_date; 
        RAISE INFO 'Amount: <%>', s_amount; 
        RAISE INFO 'Plaid Account sub type: <%>', plaid_account_subtype; 
        RAISE INFO 'Plaid Institution Id: <%>', plaid_institution_id;
        RAISE INFO 'Plaid Institution Name: <%>', matched_institution_name;
        RAISE INFO 'category level: <%>', category_levels_to_check;
        RAISE INFO 'category 0: <%>', category_level0;
        RAISE INFO 'category1: <%>', category_level1; 
        RAISE INFO 'category2: <%>', category_level2;
        RAISE INFO 'txn biz name: <%>', txn_biz_name; 
        RAISE INFO 'account ending number: <%>', ending_number;

        display_message := 'Here are the information for the matching intention';
        voice_message := display_message;
        EXIT;  -- to make sure only the first intent gets executed..

    ELSE 
        display_message := 'Sorry, there are no matching intentions for your request.';
        voice_message := display_message;
        display_type :='message_error';
    END IF;

   END LOOP;

      select * from build_entity_values_json_output (p_user_query_text, intent_name, intent_desc, display_type, display_message, voice_message, from_date, to_date, s_amount, plaid_account_subtype, plaid_institution_id, category_levels_to_check, category_level0 , category_level1, category_level2, txn_biz_name, ending_number) into results_json; 
    
    --RAISE INFO 'resulting json text: <%>', results_json;    
END;
$$  LANGUAGE plpgsql;

ALTER FUNCTION get_entity_values(p_intent_name IN text, p_user_query_text IN text, OUT results_json text) OWNER TO evadev;





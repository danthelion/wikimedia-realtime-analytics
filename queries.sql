create or replace dynamic table wikichanges_parsed
target_lag = '1 minute'
warehouse = 'DANI_TEST'
as (
    with content_json as (
        select parse_json(RECORD_CONTENT) as json_record from wikichanges
    )

    select
      json_record:bot::BOOLEAN AS bot,
      json_record:comment::STRING AS comment,
      json_record:id::INT AS id,
      json_record:meta:domain::STRING AS domain,
      json_record:meta:dt::TIMESTAMP AS dt,
      json_record:meta:id::STRING AS meta_id,
      json_record:meta:offset::INT AS offset,
      json_record:meta:partition::INT AS partition,
      json_record:meta:request_id::STRING AS request_id,
      json_record:meta:stream::STRING AS stream,
      json_record:meta:topic::STRING AS topic,
      json_record:meta:uri::STRING AS uri,
      json_record:namespace::INT AS namespace,
      json_record:notify_url::STRING AS notify_url,
      json_record:parsedcomment::STRING AS parsedcomment,
      json_record:server_name::STRING AS server_name,
      json_record:server_script_path::STRING AS server_script_path,
      json_record:server_url::STRING AS server_url,
      json_record:timestamp::TIMESTAMP AS timestamp,
      json_record:title::STRING AS title,
      json_record:title_url::STRING AS title_url,
      json_record:type::STRING AS type,
      json_record:user::STRING AS user,
      json_record:wiki::STRING AS wiki
    from content_json
);


create or replace dynamic table wikichanges_bot_edits
target_lag = '1 minute'
warehouse = 'DANI_TEST'
as (
    select
        domain
        , COUNT(CASE WHEN bot = TRUE THEN 1 END) AS bot_edits
        , COUNT(CASE WHEN bot = FALSE THEN 1 END) AS human_edits
        ,
    from wikichanges_parsed
    group by domain
    order by bot_edits desc
);

create or replace dynamic table wikichanges_most_edited
target_lag = '1 minute'
warehouse = 'DANI_TEST'
as (
    select
      title,
      uri,
      count(*) AS edit_count
    from wikichanges_parsed
    group by title, uri
    order by edit_count DESC
    limit 10
);


alter dynamic table wikichanges_bot_edits refresh;
select * from wikichanges_bot_edits;

alter dynamic table wikichanges_most_edited refresh;
select * from wikichanges_most_edited;
view: funnel_demo_view {
  derived_table: {
    sql:
select timestamp(date) as date,
sourceType as platform,
sourceName as ad_account,
dim_1b1kcbdqb_b946 as market,
dim_1b1kcdt0j_82ee as manufacturer,
dim_1b1kcia3s_0b41 as tactic,
dim_1b1kcl0eo_ac76 as product_type,
dim_1b1kcsrc3_254a as media_type,
dim_1bca8okbn_9804 as traffic_source,
dim_1bca8oljp_5eed as paid_organic,
dim_1bca8omvo_936e as campaign,
common_cost as cost,
common_clicks as clicks,
common_impressions as impressions,
common_cost,
common_clicks,
common_impressions,
googleanalytics_ga_transactionRevenue,
googleanalytics_ga_transactions,
googleanalytics_ga_sessions
FROM `firebase-funnel.funnel_demo.funnel_data_*` ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_clicks {
    type:  sum
    sql: ${clicks} ;;
  }

  measure: total_impressions {
    type:  sum
    sql: ${impressions} ;;
  }

  measure: total_cost {
    type:  sum
    sql: ${cost} ;;
  }

  measure: ctr {
    type:  number
    sql: ${total_clicks} / ${total_impressions} ;;
  }

  measure: cpc {
    type:  number
    sql: ${total_cost} / ${total_clicks} ;;
  }

  measure: total_transactions {
    type:  sum
    sql:  ${googleanalytics_ga_transactions} ;;
  }

  measure: total_revenue {
    type:  sum
    sql:  ${googleanalytics_ga_transactionRevenue} ;;
  }

  measure: total_sessions {
    type:  sum
    sql:  ${googleanalytics_ga_sessions} ;;
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}.date ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: date_year_num {
    type: number
    sql: ${TABLE}.date_year ;;
  }

  dimension: ad_account {
    type: string
    sql: ${TABLE}.ad_account ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}.market ;;
  }

  dimension: manufacturer {
    type: string
    sql: ${TABLE}.manufacturer ;;
  }

  dimension: tactic {
    type: string
    sql: ${TABLE}.tactic ;;
  }

  dimension: product_type {
    type: string
    sql: ${TABLE}.product_type ;;
  }

  dimension: media_type {
    type: string
    sql: ${TABLE}.media_type ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: paid_organic {
    type: string
    sql: ${TABLE}.paid_organic ;;
  }

  dimension: campaign {
    type: string
    sql: ${TABLE}.campaign ;;
  }

  dimension: cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.cost ;;
  }

  dimension: clicks {
    type: number
    sql: ${TABLE}.clicks ;;
  }

  dimension: impressions {
    type: number
    sql: ${TABLE}.impressions ;;
  }

  dimension: googleanalytics_ga_transactionRevenue {
    label: "Transaction revenue"
    hidden: yes
    type: number
    sql: ${TABLE}.googleanalytics_ga_transactionRevenue ;;
  }

  dimension: googleanalytics_ga_transactions {
    label: "Transactions"
    hidden: yes
    type: number
    sql: ${TABLE}.googleanalytics_ga_transactions ;;
  }

  dimension: googleanalytics_ga_sessions {
    label: "Sessions"
    hidden: yes
    type: number
    sql: ${TABLE}.googleanalytics_ga_sessions ;;
  }

  set: detail {
    fields: [
      date_time,
      platform,
      ad_account,
      market,
      manufacturer,
      tactic,
      product_type,
      media_type,
      traffic_source,
      paid_organic,
      campaign,
      cost,
      clicks,
      impressions
    ]
  }

  # this shizzle is to to date period comparisons

  dimension: timestamp {
    type:  date
    sql:  ${TABLE}.date ;;
  }

  filter: date_filter {
    description: "Use this date filter in combination with the timeframes dimension for dynamic date filtering"
    type: date
  }

  dimension_group: filter_start_date {
    type: time
    timeframes: [raw,date]
    sql: CASE WHEN {% date_start date_filter %} IS NULL THEN '1970-01-01' ELSE CAST({% date_start date_filter %} AS DATE) END;;
  }

  dimension_group: filter_end_date {
    type: time
    timeframes: [raw,date]
    sql: CASE WHEN {% date_end date_filter %} IS NULL THEN CURRENT_DATE ELSE CAST({% date_end date_filter %} AS DATE) END;;
  }

  dimension: interval {
    type: number
    sql: DATE_DIFF(${filter_start_date_raw}, ${filter_end_date_raw}, DAY);;
  }

  dimension: previous_start_date {
    type: string
    sql: DATE_ADD(${filter_start_date_raw}, INTERVAL ${interval} DAY) ;;
  }


  dimension: is_current_period {
    type: yesno
    sql: ${timestamp} >= ${filter_start_date_date} AND ${timestamp} < ${filter_end_date_date} ;;
  }

  dimension: is_previous_period {
    type: yesno
    sql: ${timestamp} >= ${previous_start_date} AND ${timestamp} < ${filter_start_date_date} ;;
  }

  dimension: timeframes {
    description: "Use this field in combination with the date filter field for dynamic date filtering"
    suggestions: ["period","previous period"]
    type: string
    case:  {
      when:  {
        sql: ${is_current_period} = true;;
        label: "Selected Period"
      }
      when: {
        sql: ${is_previous_period} = true;;
        label: "Previous Period"
      }
      else: "Not in time period"
    }
  }

}

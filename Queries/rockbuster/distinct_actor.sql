SELECT 
  COUNT(DISTINCT actor_first_name || actor_last_name)
FROM analytics._stg_rockbuster;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT version, description, success, installed_on
FROM public.flyway_schema_history
ORDER BY installed_rank;

SELECT
  (SELECT count(*) FROM public.products) AS products,
  (SELECT count(*) FROM public.categories) AS categories,
  (SELECT count(*) FROM public.banners) AS banners,
  (SELECT count(*) FROM public.offers) AS offers,
  (SELECT count(*) FROM public.farmers) AS farmers,
  (SELECT count(*) FROM public.delivery_slots) AS delivery_slots,
  (SELECT count(*) FROM public.app_users) AS app_users,
  (SELECT count(*) FROM public.orders) AS orders,
  (SELECT count(*) FROM public.notifications) AS notifications;

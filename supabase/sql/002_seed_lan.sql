-- Seed: kartan_platser — riktiga län (21 st), centroider beräknade från verklig geodata
-- Källa: okfse/sweden-geojson (bearbetad med shapely: simplify + representative_point)

insert into kartan_platser (id, typ, namn, lan_code, lat, lon) values
  ('1', 'lan', 'Stockholm', null, 59.5166, 18.0225),
  ('10', 'lan', 'Blekinge', null, 56.2471, 15.2706),
  ('12', 'lan', 'Skåne', null, 55.92, 13.556),
  ('13', 'lan', 'Halland', null, 56.9477, 13.0108),
  ('14', 'lan', 'Västra Götaland', null, 58.2118, 13.1433),
  ('17', 'lan', 'Värmland', null, 59.9002, 13.2846),
  ('18', 'lan', 'Örebro', null, 59.3549, 15.0039),
  ('19', 'lan', 'Västmanland', null, 59.7629, 16.1881),
  ('20', 'lan', 'Dalarna', null, 61.0956, 14.2386),
  ('21', 'lan', 'Gävleborg', null, 61.2772, 16.3696),
  ('22', 'lan', 'Västernorrland', null, 63.0906, 17.6499),
  ('23', 'lan', 'Jämtland', null, 63.3334, 14.1609),
  ('24', 'lan', 'Västerbotten', null, 64.9179, 18.0307),
  ('25', 'lan', 'Norrbotten', null, 67.0511, 20.0471),
  ('3', 'lan', 'Uppsala', null, 59.9634, 17.8108),
  ('4', 'lan', 'Södermanland', null, 59.0656, 16.5163),
  ('5', 'lan', 'Östergötland', null, 58.381, 15.6605),
  ('6', 'lan', 'Jönköping', null, 57.5373, 14.646),
  ('7', 'lan', 'Kronoberg', null, 56.7908, 14.3965),
  ('8', 'lan', 'Kalmar', null, 57.236, 16.007),
  ('9', 'lan', 'Gotland', null, 57.4218, 18.5385)
on conflict (id) do update set namn = excluded.namn, lat = excluded.lat, lon = excluded.lon;

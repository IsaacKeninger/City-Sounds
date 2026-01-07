-- City Artists Data - Artists matched to cities based on musical heritage and cultural significance
-- City IDs must match the order in citiesData.sql
INSERT INTO city_artists (city_id, artist_name, spotify_artist_id) VALUES
-- 1. New York (Hip Hop)
(1, 'Jay-Z', NULL),
(1, 'Nas', NULL),
(1, 'Wu-Tang Clan', NULL),
(1, 'The Notorious B.I.G.', NULL),

-- 2. Los Angeles (Pop)
(2, 'Kendrick Lamar', NULL),
(2, 'Dr. Dre', NULL),
(2, 'Snoop Dogg', NULL),
(2, 'The Beach Boys', NULL),

-- 3. Chicago (Blues)
(3, 'Muddy Waters', NULL),
(3, 'Buddy Guy', NULL),
(3, 'Kanye West', NULL),
(3, 'Common', NULL),

-- 4. Nashville (Country)
(4, 'Johnny Cash', NULL),
(4, 'Dolly Parton', NULL),
(4, 'Taylor Swift', NULL),
(4, 'Chris Stapleton', NULL),

-- 5. New Orleans (Jazz)
(5, 'Louis Armstrong', NULL),
(5, 'Dr. John', NULL),
(5, 'Wynton Marsalis', NULL),
(5, 'Allen Toussaint', NULL),

-- 6. Detroit (Motown)
(6, 'Stevie Wonder', NULL),
(6, 'Marvin Gaye', NULL),
(6, 'The Temptations', NULL),
(6, 'Eminem', NULL),

-- 7. Memphis (Soul)
(7, 'Al Green', NULL),
(7, 'Isaac Hayes', NULL),
(7, 'Otis Redding', NULL),
(7, 'Elvis Presley', NULL),

-- 8. Seattle (Grunge)
(8, 'Nirvana', NULL),
(8, 'Pearl Jam', NULL),
(8, 'Soundgarden', NULL),
(8, 'Alice in Chains', NULL),

-- 9. Miami (Latin)
(9, 'Gloria Estefan', NULL),
(9, 'Pitbull', NULL),
(9, 'Camila Cabello', NULL),
(9, 'Bad Bunny', NULL),

-- 10. Toronto (Hip Hop)
(10, 'Drake', NULL),
(10, 'The Weeknd', NULL),
(10, 'PartyNextDoor', NULL),
(10, 'Tory Lanez', NULL),

-- 11. Montreal (Indie)
(11, 'Arcade Fire', NULL),
(11, 'Leonard Cohen', NULL),
(11, 'Godspeed You! Black Emperor', NULL),
(11, 'Grimes', NULL),

-- 12. Mexico City (Mariachi)
(12, 'Vicente Fernandez', NULL),
(12, 'Luis Miguel', NULL),
(12, 'Pedro Infante', NULL),
(12, 'Mariachi Vargas de Tecalitlan', NULL),

-- 13. Havana (Salsa)
(13, 'Buena Vista Social Club', NULL),
(13, 'Celia Cruz', NULL),
(13, 'Compay Segundo', NULL),
(13, 'Omara Portuondo', NULL),

-- 14. Rio de Janeiro (Bossa Nova)
(14, 'Antonio Carlos Jobim', NULL),
(14, 'Joao Gilberto', NULL),
(14, 'Stan Getz', NULL),
(14, 'Astrud Gilberto', NULL),

-- 15. Sao Paulo (Samba)
(15, 'Jorge Ben Jor', NULL),
(15, 'Cartola', NULL),
(15, 'Alcione', NULL),
(15, 'Elza Soares', NULL),

-- 16. Buenos Aires (Tango)
(16, 'Astor Piazzolla', NULL),
(16, 'Carlos Gardel', NULL),
(16, 'Gotan Project', NULL),
(16, 'Anibal Troilo', NULL),

-- 17. Bogota (Cumbia)
(17, 'Carlos Vives', NULL),
(17, 'Shakira', NULL),
(17, 'Bomba Estereo', NULL),
(17, 'ChocQuibTown', NULL),

-- 18. Lima (Cumbia)
(18, 'Chabuca Granda', NULL),
(18, 'Eva Ayllon', NULL),
(18, 'Susana Baca', NULL),
(18, 'Los Mirla', NULL),

-- 19. London (Rock)
(19, 'The Beatles', NULL),
(19, 'The Rolling Stones', NULL),
(19, 'Pink Floyd', NULL),
(19, 'Queen', NULL),

-- 20. Liverpool (Rock)
(20, 'The Beatles', NULL),
(20, 'Echo & the Bunnymen', NULL),
(20, 'The La''s', NULL),
(20, 'Frankie Goes to Hollywood', NULL),

-- 21. Manchester (Indie)
(21, 'The Smiths', NULL),
(21, 'Oasis', NULL),
(21, 'Joy Division', NULL),
(21, 'The Stone Roses', NULL),

-- 22. Paris (Chanson)
(22, 'Edith Piaf', NULL),
(22, 'Serge Gainsbourg', NULL),
(22, 'Charles Aznavour', NULL),
(22, 'Zaz', NULL),

-- 23. Berlin (Electronic)
(23, 'Paul Kalkbrenner', NULL),
(23, 'Ellen Allien', NULL),
(23, 'Kraftwerk', NULL),
(23, 'Modeselektor', NULL),

-- 24. Vienna (Classical)
(24, 'Wolfgang Amadeus Mozart', NULL),
(24, 'Ludwig van Beethoven', NULL),
(24, 'Franz Schubert', NULL),
(24, 'Johann Strauss II', NULL),

-- 25. Amsterdam (Electronic)
(25, 'Tiesto', NULL),
(25, 'Armin van Buuren', NULL),
(25, 'Martin Garrix', NULL),
(25, 'Afrojack', NULL),

-- 26. Dublin (Folk)
(26, 'U2', NULL),
(26, 'The Dubliners', NULL),
(26, 'The Pogues', NULL),
(26, 'Sinead O''Connor', NULL),

-- 27. Barcelona (Flamenco)
(27, 'Paco de Lucia', NULL),
(27, 'Rosalia', NULL),
(27, 'Camaron de la Isla', NULL),
(27, 'Gipsy Kings', NULL),

-- 28. Rome (Opera)
(28, 'Andrea Bocelli', NULL),
(28, 'Luciano Pavarotti', NULL),
(28, 'Ennio Morricone', NULL),
(28, 'Enrico Caruso', NULL),

-- 29. Milan (Opera)
(29, 'Giuseppe Verdi', NULL),
(29, 'Maria Callas', NULL),
(29, 'Renata Tebaldi', NULL),
(29, 'Claudio Abbado', NULL),

-- 30. Stockholm (Pop)
(30, 'ABBA', NULL),
(30, 'Roxette', NULL),
(30, 'Robyn', NULL),
(30, 'Avicii', NULL),

-- 31. Moscow (Classical)
(31, 'Vladimir Ashkenazy', '6ZLkdc8awNT87a3gMmJfKD'),
(31, 'Valery Gergiev', '7zw0bRBO3yYHBzfGwBT5C3'),
(31, 'Moscow Philharmonic Orchestra', '3QiAAp20rJ4NfClKSOWOWw'),
(31, 'Yuja Wang', '4unciu3P0vbF3V0X9GEH7u'),

-- 32. Lagos (Afrobeat)
(32, 'Fela Kuti', NULL),
(32, 'Wizkid', NULL),
(32, 'Burna Boy', NULL),
(32, 'Tiwa Savage', NULL),

-- 33. Johannesburg (Jazz)
(33, 'Hugh Masekela', NULL),
(33, 'Miriam Makeba', NULL),
(33, 'Abdullah Ibrahim', NULL),
(33, 'Black Coffee', NULL),

-- 34. Cairo (Arabic Pop)
(34, 'Umm Kulthum', NULL),
(34, 'Amr Diab', NULL),
(34, 'Mohamed Mounir', NULL),
(34, 'Sherine', NULL),

-- 35. Accra (Highlife)
(35, 'E.T. Mensah', NULL),
(35, 'Sarkodie', NULL),
(35, 'Shatta Wale', NULL),
(35, 'Stonebwoy', NULL),

-- 36. Istanbul (Turkish Pop)
(36, 'Tarkan', NULL),
(36, 'Sezen Aksu', NULL),
(36, 'Baris Manco', NULL),
(36, 'Sertab Erener', NULL),

-- 37. Dubai (Arabic Pop)
(37, 'Hussain Al Jassmi', NULL),
(37, 'Balqees', NULL),
(37, 'Nancy Ajram', NULL),
(37, 'Elissa', NULL),

-- 38. Tel Aviv (Electronic)
(38, 'Infected Mushroom', NULL),
(38, 'Omer Adam', NULL),
(38, 'Static & Ben El Tavori', NULL),
(38, 'Netta', NULL),

-- 39. Tokyo (J-Pop)
(39, 'Hikaru Utada', NULL),
(39, 'Perfume', NULL),
(39, 'King Gnu', NULL),
(39, 'RADWIMPS', NULL),

-- 40. Osaka (J-Pop)
(40, 'Kanjani Eight', NULL),
(40, 'NMB48', NULL),
(40, 'Dragon Ash', NULL),
(40, 'Ketsumeishi', NULL),

-- 41. Seoul (K-Pop)
(41, 'BTS', NULL),
(41, 'BLACKPINK', NULL),
(41, 'EXO', NULL),
(41, 'TWICE', NULL),

-- 42. Beijing (Mandopop)
(42, 'Faye Wong', NULL),
(42, 'Cui Jian', NULL),
(42, 'Li Yuchun', NULL),
(42, 'TFBoys', NULL),

-- 43. Shanghai (Mandopop)
(43, 'Jay Chou', NULL),
(43, 'Eason Chan', NULL),
(43, 'JJ Lin', NULL),
(43, 'G.E.M.', NULL),

-- 44. Hong Kong (Cantopop)
(44, 'Leslie Cheung', NULL),
(44, 'Anita Mui', NULL),
(44, 'Beyond', NULL),
(44, 'Jacky Cheung', NULL),

-- 45. Mumbai (Bollywood)
(45, 'A.R. Rahman', NULL),
(45, 'Lata Mangeshkar', NULL),
(45, 'Arijit Singh', NULL),
(45, 'Shreya Ghoshal', NULL),

-- 46. Bangkok (Thai Pop)
(46, 'Bird Thongchai', NULL),
(46, 'Carabao', NULL),
(46, 'Tata Young', NULL),
(46, 'Palmy', NULL),

-- 47. Singapore (Pop)
(47, 'Stefanie Sun', NULL),
(47, 'JJ Lin', NULL),
(47, 'Tanya Chua', NULL),
(47, 'The Sam Willows', NULL),

-- 48. Manila (OPM)
(48, 'Eraserheads', NULL),
(48, 'Freddie Aguilar', NULL),
(48, 'Sarah Geronimo', NULL),
(48, 'Regine Velasquez', NULL),

-- 49. Sydney (Rock)
(49, 'AC/DC', NULL),
(49, 'INXS', NULL),
(49, 'Midnight Oil', NULL),
(49, 'Men at Work', NULL),

-- 50. Melbourne (Indie)
(50, 'Tame Impala', NULL),
(50, 'Nick Cave and the Bad Seeds', NULL),
(50, 'King Gizzard & The Lizard Wizard', NULL),
(50, 'Courtney Barnett', NULL),

-- 51. Auckland (Indie)
(51, 'Fat Freddy''s Drop', NULL),
(51, 'Six60', NULL),
(51, 'Katchafire', NULL),
(51, 'L.A.B.', NULL);

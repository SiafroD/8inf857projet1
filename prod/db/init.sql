-- Runs once, the first time the postgres volume is empty.
CREATE TABLE users (
    id       SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    pw_hash  TEXT NOT NULL
);
-- The admin row is seeded by the backend at start, so the hash is computed there.

CREATE TABLE products (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL,
    price NUMERIC(8, 2) NOT NULL
);

INSERT INTO products (name, price) VALUES
    ('Perceuse sans fil 18V', 149.99),
    ('Jeu de tournevis 12 pièces', 24.50),
    ('Ruban à mesurer 8 m', 12.95),
    ('Scie circulaire 1400W', 89.00),
    ('Boîte à outils acier', 39.99),
    ('Niveau laser', 74.25);

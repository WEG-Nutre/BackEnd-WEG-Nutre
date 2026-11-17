BEGIN;

-- =========================================================
-- USUÁRIOS
-- =========================================================

CREATE TABLE tb_usuario_nutricionista (
    id_usuario_nutricionista INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nome      VARCHAR(150) NOT NULL,
    email     VARCHAR(254) NOT NULL UNIQUE,
    login     VARCHAR(100) NOT NULL UNIQUE,
    senha     VARCHAR(255) NOT NULL,
    matricula VARCHAR(30)  NOT NULL UNIQUE,
    crn       VARCHAR(30)  NOT NULL UNIQUE
);

CREATE TABLE tb_usuario_ti (
    id_usuario_ti INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nome  VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    login VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL
);

CREATE TABLE tb_usuario_colaborador (
    id_usuario_colaborador INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nome      VARCHAR(150) NOT NULL,
    email     VARCHAR(254) NOT NULL UNIQUE,
    login     VARCHAR(100) NOT NULL UNIQUE,
    senha     VARCHAR(255) NOT NULL,
    matricula VARCHAR(30)  NOT NULL UNIQUE,
    crn       VARCHAR(30)
);

-- A coluna senha deve armazenar o hash gerado pela aplicação.

COMMENT ON COLUMN tb_usuario_colaborador.crn IS
    'Mantido conforme o DER. Confirmar se se aplica ao colaborador.';


-- =========================================================
-- FEEDBACK
-- =========================================================

CREATE TABLE tb_feedback (
    id_feedback INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    descricao TEXT,
    nota      NUMERIC(5, 2) NOT NULL CHECK (nota >= 0)
);


-- =========================================================
-- ALÉRGENOS
-- =========================================================

CREATE TABLE tb_alergeno (
    id_alergeno INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nome VARCHAR(100) NOT NULL
);


-- =========================================================
-- INGREDIENTES
-- =========================================================

CREATE TABLE tb_ingrediente (
    id_ingrediente INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nome            VARCHAR(150) NOT NULL,
    preco           NUMERIC(12, 2) NOT NULL CHECK (preco >= 0),
    "unidadeMedida"  VARCHAR(20) NOT NULL,
    quantidade      NUMERIC(12, 3) NOT NULL CHECK (quantidade >= 0),
    vegetariano     BOOLEAN NOT NULL DEFAULT FALSE,

    calorias        NUMERIC(12, 3) CHECK (calorias >= 0),
    proteinas       NUMERIC(12, 3) CHECK (proteinas >= 0),
    gorduras        NUMERIC(12, 3) CHECK (gorduras >= 0),
    carboidratos    NUMERIC(12, 3) CHECK (carboidratos >= 0)
);


-- =========================================================
-- PRATOS
-- =========================================================

CREATE TABLE tb_prato (
    id_prato INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nome            VARCHAR(150) NOT NULL,
    descricao       TEXT,
    preco           NUMERIC(12, 2) NOT NULL CHECK (preco >= 0),
    porcao_gramas    NUMERIC(12, 3) NOT NULL CHECK (porcao_gramas > 0),

    calorias        NUMERIC(12, 3) CHECK (calorias >= 0),
    proteinas       NUMERIC(12, 3) CHECK (proteinas >= 0),
    gorduras        NUMERIC(12, 3) CHECK (gorduras >= 0),
    carboidratos    NUMERIC(12, 3) CHECK (carboidratos >= 0),

    categoria_prato VARCHAR(100) NOT NULL,
    modo_de_preparo TEXT
);


-- =========================================================
-- CARDÁPIOS
-- =========================================================

CREATE TABLE tb_cardapio (
    id_cardapio INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nutricionista         INTEGER NOT NULL,
    data                  DATE NOT NULL,

    "metaTetoCusto"        NUMERIC(14, 2) NOT NULL
                          CHECK ("metaTetoCusto" >= 0),

    aprovado              BOOLEAN NOT NULL DEFAULT FALSE,

    "quantidadeRefeicoes"  INTEGER NOT NULL
                          CHECK ("quantidadeRefeicoes" >= 0),

    nota                  NUMERIC(5, 2) CHECK (nota >= 0),

    "qtdProduzida"         INTEGER CHECK ("qtdProduzida" >= 0),
    "qtdDesperdicio"       INTEGER CHECK ("qtdDesperdicio" >= 0),
    "qtdExcedente"         INTEGER CHECK ("qtdExcedente" >= 0),

    CONSTRAINT fk_cardapio_nutricionista
        FOREIGN KEY (nutricionista)
        REFERENCES tb_usuario_nutricionista (
            id_usuario_nutricionista
        )
        ON DELETE RESTRICT
);


-- =========================================================
-- RELACIONAMENTO: PRATO × CARDÁPIO
-- =========================================================

CREATE TABLE tb_prato_cardapio (
    id_prato_cardapio INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_prato    INTEGER NOT NULL,
    id_cardapio INTEGER NOT NULL,

    CONSTRAINT fk_prato_cardapio_prato
        FOREIGN KEY (id_prato)
        REFERENCES tb_prato (id_prato)
        ON DELETE RESTRICT,

    CONSTRAINT fk_prato_cardapio_cardapio
        FOREIGN KEY (id_cardapio)
        REFERENCES tb_cardapio (id_cardapio)
        ON DELETE RESTRICT,

    CONSTRAINT uq_prato_cardapio
        UNIQUE (id_prato, id_cardapio)
);


-- =========================================================
-- RELACIONAMENTO: PRATO × INGREDIENTE
-- =========================================================

CREATE TABLE tb_prato_ingrediente (
    id_prato_ingrediente INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_prato       INTEGER NOT NULL,
    id_ingrediente INTEGER NOT NULL,
    porcao         NUMERIC(12, 3) NOT NULL CHECK (porcao > 0),

    CONSTRAINT fk_prato_ingrediente_prato
        FOREIGN KEY (id_prato)
        REFERENCES tb_prato (id_prato)
        ON DELETE RESTRICT,

    CONSTRAINT fk_prato_ingrediente_ingrediente
        FOREIGN KEY (id_ingrediente)
        REFERENCES tb_ingrediente (id_ingrediente)
        ON DELETE RESTRICT,

    CONSTRAINT uq_prato_ingrediente
        UNIQUE (id_prato, id_ingrediente)
);


-- =========================================================
-- RELACIONAMENTO: PRATO × ALÉRGENO
-- =========================================================

CREATE TABLE tb_prato_alergeno (
    id_prato_alergeno INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_prato    INTEGER NOT NULL,
    id_alergeno INTEGER NOT NULL,

    CONSTRAINT fk_prato_alergeno_prato
        FOREIGN KEY (id_prato)
        REFERENCES tb_prato (id_prato)
        ON DELETE RESTRICT,

    CONSTRAINT fk_prato_alergeno_alergeno
        FOREIGN KEY (id_alergeno)
        REFERENCES tb_alergeno (id_alergeno)
        ON DELETE RESTRICT,

    CONSTRAINT uq_prato_alergeno
        UNIQUE (id_prato, id_alergeno)
);


-- =========================================================
-- RELACIONAMENTO: FEEDBACK × PRATO
-- =========================================================

CREATE TABLE tb_feedback_prato (
    id_feedback_prato INTEGER
        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_prato    INTEGER NOT NULL,
    id_feedback INTEGER NOT NULL,

    CONSTRAINT fk_feedback_prato_prato
        FOREIGN KEY (id_prato)
        REFERENCES tb_prato (id_prato)
        ON DELETE RESTRICT,

    CONSTRAINT fk_feedback_prato_feedback
        FOREIGN KEY (id_feedback)
        REFERENCES tb_feedback (id_feedback)
        ON DELETE RESTRICT,

    CONSTRAINT uq_feedback_prato
        UNIQUE (id_prato, id_feedback)
);


-- =========================================================
-- ÍNDICES PARA AS CHAVES ESTRANGEIRAS
-- PKs e UNIQUEs já geram seus próprios índices.
-- Os índices abaixo cobrem as FKs restantes.
-- =========================================================

CREATE INDEX idx_cardapio_nutricionista
    ON tb_cardapio (nutricionista);

CREATE INDEX idx_prato_cardapio_cardapio
    ON tb_prato_cardapio (id_cardapio);

CREATE INDEX idx_prato_ingrediente_ingrediente
    ON tb_prato_ingrediente (id_ingrediente);

CREATE INDEX idx_prato_alergeno_alergeno
    ON tb_prato_alergeno (id_alergeno);

CREATE INDEX idx_feedback_prato_feedback
    ON tb_feedback_prato (id_feedback);

COMMIT;
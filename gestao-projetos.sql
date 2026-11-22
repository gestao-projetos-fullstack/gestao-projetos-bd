-- =====================================================================
-- Banco de dados: Projeto Full Stack (Do Zero ao Full Stack)
-- SGBD: MySQL 8.0+ (InnoDB, utf8mb4)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS gestao_projetos
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE gestao_projetos;

-- ---------------------------------------------------------------------
-- Remoção das tabelas (ordem inversa das dependências) para reexecução
-- ---------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS tarefa_usuario;
DROP TABLE IF EXISTS projeto_usuario;
DROP TABLE IF EXISTS tarefa;
DROP TABLE IF EXISTS projeto;
DROP TABLE IF EXISTS usuario;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- Tabela: usuario
-- ---------------------------------------------------------------------
CREATE TABLE usuario (
    id_usuario       BIGINT        NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(150)  NOT NULL,
    descricao        TEXT,
    email            VARCHAR(255)  NOT NULL,
    senha            VARCHAR(255)  NOT NULL,            -- armazenar sempre com hash (ex.: BCrypt)
    data_nascimento  DATE,
    status           ENUM('ATIVO', 'INATIVO', 'BLOQUEADO') NOT NULL DEFAULT 'ATIVO',

    CONSTRAINT pk_usuario       PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuario_email UNIQUE (email),
    CONSTRAINT ck_usuario_email CHECK (email LIKE '%_@_%.__%')
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Tabela: projeto
-- ---------------------------------------------------------------------
CREATE TABLE projeto (
    id_projeto       BIGINT        NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(150)  NOT NULL,
    descricao        TEXT,
    data_inicio      DATE,
    data_conclusao   DATE,
    status           ENUM('ATIVO', 'CONCLUIDO', 'CANCELADO') NOT NULL DEFAULT 'ATIVO',
    id_responsavel   BIGINT,

    CONSTRAINT pk_projeto            PRIMARY KEY (id_projeto),
    CONSTRAINT ck_projeto_datas      CHECK (data_conclusao IS NULL OR data_inicio IS NULL OR data_conclusao >= data_inicio),
    CONSTRAINT fk_projeto_responsavel FOREIGN KEY (id_responsavel)
        REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Tabela: tarefa (1:N com projeto)
-- ---------------------------------------------------------------------
CREATE TABLE tarefa (
    id_tarefa        BIGINT        NOT NULL AUTO_INCREMENT,
    titulo           VARCHAR(200)  NOT NULL,
    descricao        TEXT,
    data_criacao     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_conclusao   DATETIME,
    prioridade       ENUM('BAIXA', 'MEDIA', 'ALTA') NOT NULL DEFAULT 'MEDIA',
    status           ENUM('PENDENTE', 'FAZENDO', 'FEITO') NOT NULL DEFAULT 'PENDENTE',
    id_projeto       BIGINT        NOT NULL,

    CONSTRAINT pk_tarefa          PRIMARY KEY (id_tarefa),
    CONSTRAINT ck_tarefa_datas    CHECK (data_conclusao IS NULL OR data_conclusao >= data_criacao),
    CONSTRAINT fk_tarefa_projeto  FOREIGN KEY (id_projeto)
        REFERENCES projeto (id_projeto)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Tabela associativa: projeto_usuario (N:N - participantes do projeto)
-- ---------------------------------------------------------------------
CREATE TABLE projeto_usuario (
    id_projeto       BIGINT        NOT NULL,
    id_usuario       BIGINT        NOT NULL,
    data_entrada     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_projeto_usuario PRIMARY KEY (id_projeto, id_usuario),
    CONSTRAINT fk_pu_projeto      FOREIGN KEY (id_projeto)
        REFERENCES projeto (id_projeto)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_pu_usuario      FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Tabela associativa: tarefa_usuario (N:N - usuários associados à tarefa)
-- ---------------------------------------------------------------------
CREATE TABLE tarefa_usuario (
    id_tarefa        BIGINT        NOT NULL,
    id_usuario       BIGINT        NOT NULL,
    data_associacao  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_tarefa_usuario PRIMARY KEY (id_tarefa, id_usuario),
    CONSTRAINT fk_tu_tarefa      FOREIGN KEY (id_tarefa)
        REFERENCES tarefa (id_tarefa)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_tu_usuario     FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Índices para consultas frequentes
-- (no MySQL, o índice de FK é criado automaticamente; os abaixo
--  cobrem filtros por status e as FKs das tabelas associativas)
-- ---------------------------------------------------------------------
CREATE INDEX idx_projeto_status   ON projeto (status);
CREATE INDEX idx_tarefa_status    ON tarefa (status);
CREATE INDEX idx_pu_usuario       ON projeto_usuario (id_usuario);
CREATE INDEX idx_tu_usuario       ON tarefa_usuario (id_usuario);
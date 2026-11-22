# Gestão de Projetos: Banco de Dados (MySQL)

Scripts SQL do banco de dados do projeto do curso **Do Zero ao Full Stack**, usado pela API em Java com Spring Boot.

## Conteúdo

| Arquivo      | Descrição                                                        |
|--------------|------------------------------------------------------------------|
| `gestao-projetos.sql` | Cria o banco `gestao_projetos`, as tabelas, chaves, restrições e índices |
| `README.md`  | Este documento                                                   |

## Requisitos

- MySQL 8.0 ou superior (o `CHECK` no e-mail só é aplicado a partir da versão 8.0.16)
- Cliente MySQL (linha de comando, MySQL Workbench, DBeaver ou similar)
- Usuário com permissão para criar bancos e tabelas

## Como executar

### Opção 1: linha de comando

```bash
mysql -u root -p < gestao-projetos.sql
```

### Opção 2: MySQL Workbench

1. Abra o arquivo `gestao-projetos.sql`.
2. Clique em **Execute** (ícone de raio) ou pressione `Ctrl+Shift+Enter`.

### Opção 3: dentro do cliente MySQL

```sql
SOURCE /caminho/para/gestao-projetos.sql;
```

> **Atenção:** o script começa removendo as tabelas existentes (`DROP TABLE IF EXISTS`). Executá-lo novamente **apaga todos os dados**. Use apenas em desenvolvimento ou quando quiser recriar o banco do zero.

## Modelo de dados

```
usuario ─────────┬──────────────┐
  │ 1           │ N            │ N
  │ responsavel │              │
  ▼             ▼              ▼
projeto ◄──── projeto_usuario   tarefa_usuario ────► usuario
  │ 1                              ▲ N
  │ contém                         │ 1
  └──────────────► tarefa ─────────┘
              N
```

### Tabelas

| Tabela           | Tipo              | Descrição                                              |
|------------------|-------------------|--------------------------------------------------------|
| `usuario`        | Entidade          | Pessoas que usam o sistema (gestores, membros da equipe) |
| `projeto`        | Entidade          | Agrupa um conjunto de tarefas                          |
| `tarefa`         | Entidade          | Atividade específica dentro de um projeto              |
| `projeto_usuario`| Associativa (N:N) | Participantes de cada projeto                          |
| `tarefa_usuario` | Associativa (N:N) | Usuários associados a cada tarefa                      |

### Relacionamentos

- **Projeto → Tarefa (1:N):** cada tarefa pertence a um único projeto. Ao excluir o projeto, suas tarefas são excluídas (`ON DELETE CASCADE`).
- **Usuário → Projeto, como responsável (N:1):** `projeto.id_responsavel` referencia `usuario`. Ao excluir o usuário, o campo vai para `NULL` (`ON DELETE SET NULL`).
- **Projeto ↔ Usuário (N:N):** através de `projeto_usuario`.
- **Tarefa ↔ Usuário (N:N):** através de `tarefa_usuario`.

### Valores permitidos (ENUM)

| Campo                | Valores                              | Padrão     |
|----------------------|--------------------------------------|------------|
| `usuario.status`     | `ATIVO`, `INATIVO`, `BLOQUEADO`      | `ATIVO`    |
| `projeto.status`     | `ATIVO`, `CONCLUIDO`, `CANCELADO`    | `ATIVO`    |
| `tarefa.prioridade`  | `BAIXA`, `MEDIA`, `ALTA`             | `MEDIA`    |
| `tarefa.status`      | `PENDENTE`, `FAZENDO`, `FEITO`       | `PENDENTE` |

### Regras de integridade

- `usuario.email` é único.
- `projeto.data_conclusao` não pode ser anterior a `data_inicio`.
- `tarefa.data_conclusao` não pode ser anterior a `data_criacao`.
- As chaves primárias são `BIGINT AUTO_INCREMENT`, exceto nas tabelas associativas, que usam chave composta.

## Configuração no Spring Boot

Exemplo de `application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/gestao_projetos?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=seu_usuario
spring.datasource.password=sua_senha

# O banco é criado pelo gestao-projetos.sql; o Hibernate apenas valida o mapeamento
spring.jpa.hibernate.ddl-auto=validate
```

Ao mapear as entidades:

- Use `@Enumerated(EnumType.STRING)` nos campos `ENUM`, com enums Java de mesmo nome (`ATIVO`, `FAZENDO` etc.).
- Armazene a senha sempre como hash (BCrypt), nunca em texto puro.

## Observações

- O banco usa `utf8mb4` com collation `utf8mb4_unicode_ci`, o que suporta acentos e emojis.
- Os campos de data e hora usam `DATETIME` em vez de `TIMESTAMP`, para evitar conversões de fuso horário e o limite de 2038.
- As chaves estrangeiras geram índices automaticamente no MySQL. Os índices explícitos cobrem os filtros por `status` e as consultas por usuário nas tabelas associativas.
- Para alterar o schema no futuro, prefira criar novos scripts de migração (por exemplo, uma pasta `migrations/`) em vez de editar o `gestao-projetos.sql` já aplicado.

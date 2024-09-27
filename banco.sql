-- Criação do banco de dados
CREATE DATABASE tcc_tracking_system;
USE tcc_tracking_system;

-- Tabela de alunos
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL
);

CREATE TABLE alunos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    matricula VARCHAR(50) NOT NULL UNIQUE,
    id_usuario INT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE
)

CREATE TABLE professores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE
)

-- Tabela de grupos
CREATE TABLE grupos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_tutor INT,
    numero int NOT NULL,
    nome VARCHAR(255),
    descricao VARCHAR(255),
    ano INT NOT NULL -- Ano de formação do grupo
    FOREIGN KEY (id_tutor) REFERENCES professores(id) ON DELETE CASCADE
);

-- Tabela de relacionamento entre alunos e grupos (um aluno pode estar em diferentes grupos em anos diferentes)
CREATE TABLE grupo_aluno (
    id_grupo INT,
    id_aluno INT,
    cargo ENUM('PO', 'Líder Técnico', 'Líder UX/UI', 'Desenvolvedor') DEFAULT 'Desenvolvedor',
    PRIMARY KEY (id_grupo, id_aluno),
    FOREIGN KEY (id_grupo) REFERENCES grupos(id) ON DELETE CASCADE, -- Se o grupo for deletado, as relações também serão
    FOREIGN KEY (id_aluno) REFERENCES alunos(id) ON DELETE CASCADE  -- Se o aluno for deletado, as relações também serão
);

-- Tabela de atividades
CREATE TABLE atividades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_grupo INT,
    id_periodo_criacao INT,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    status ENUM('em_andamento', 'concluida') DEFAULT 'em_andamento',
    FOREIGN KEY (id_periodo) REFERENCES periodos(id) ON DELETE CASCADE -- Se o periodo for deletado, a atividade também será
    FOREIGN KEY (id_grupo) REFERENCES grupos(id) ON DELETE CASCADE -- Se o grupo for deletado, a atividade também será
);

-- Tabela de períodos
CREATE TABLE periodos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL
);

-- Tabela de vinculação entre atividades, períodos e alunos
CREATE TABLE alocacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT,
    id_atividade INT,
    id_periodo INT,
    FOREIGN KEY (id_aluno) REFERENCES alunos(id) ON DELETE CASCADE,
    FOREIGN KEY (id_atividade) REFERENCES atividades(id) ON DELETE CASCADE,
    FOREIGN KEY (id_periodo) REFERENCES periodos(id) ON DELETE CASCADE
);

-- Tabela de registros (logs diários das atividades)
CREATE TABLE registros (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_alocacao INT,
    data_registro DATE NOT NULL,
    descricao_atividade TEXT NOT NULL,
    horas_trabalhadas DECIMAL(5, 2),
    FOREIGN KEY (id_alocacao) REFERENCES alocacoes(id) ON DELETE CASCADE
);

-- Trigger para impedir inserção em atividades/alocações com período passado
DELIMITER $$

-- Trigger para impedir inserção de nova alocação se o período já passou
CREATE TRIGGER before_insert_alocacao
BEFORE INSERT ON alocacoes
FOR EACH ROW
BEGIN
    DECLARE v_data_fim DATE;
    
    -- Obter a data de término do período relacionado à alocação
    SELECT data_fim INTO v_data_fim
    FROM periodos
    WHERE id = NEW.id_periodo;
    
    -- Verifica se o período já passou
    IF v_data_fim < CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Não é possível inserir uma nova alocação para um período que já passou.';
    END IF;
END$$

-- Trigger para impedir atualização de uma alocação se o período já passou
CREATE TRIGGER before_update_alocacao
BEFORE UPDATE ON alocacoes
FOR EACH ROW
BEGIN
    DECLARE v_data_fim DATE;
    
    -- Obter a data de término do período relacionado à alocação
    SELECT data_fim INTO v_data_fim
    FROM periodos
    WHERE id = OLD.id_periodo; -- Usar o período antigo da alocação
    
    -- Verifica se o período já passou
    IF v_data_fim < CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Não é possível alterar uma alocação para um período que já passou.';
    END IF;
END$$

DELIMITER ;

-- Inserção de pessoas
INSERT INTO usuarios (nome, email, senha) VALUES
('João Silva', 'joao.silva@example.com', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'), --senha: admin
('Maria Souza', 'maria.souza@example.com', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'), --senha: admin
('Carlos Oliveira', 'carlos.oliveira@example.com', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'), --senha: admin
('Ana Clara', 'ana.clara@example.com', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'), --senha: admin
('Pedro Santos', 'pedro.santos@example.com', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'), --senha: admin
('Admin', 'admin@example.com', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'); --senha: admin

-- Inserção de alunos (considerando que os IDs de pessoas são 1 a 5)
INSERT INTO alunos (matricula, id_usuario) VALUES
('2021001', 1),
('2021002', 2),
('2021003', 3),
('2021004', 4),
('2021005', 5);

-- Inserção de alunos (considerando que os IDs de pessoas são 1 a 5)
INSERT INTO professores (id_usuario) VALUES
(6),

-- Inserção de grupos
INSERT INTO grupos (numero, ano) VALUES
(1, 2023),
(1, 2024),
(2, 2024);

-- Inserção de atividades
INSERT INTO atividades (id_grupo, nome, descricao, status) VALUES
(1, 'Desenvolvimento do Sistema', 'Desenvolver o backend do sistema.', 'em_andamento'),
(1, 'Documentação do Projeto', 'Escrever a documentação final do projeto.', 'em_andamento'),
(2, 'Pesquisa de Usuário', 'Realizar entrevistas com os usuários.', 'em_andamento');

-- Inserção de períodos
INSERT INTO periodos (nome, data_inicio, data_fim) VALUES
('Sprint 01', '2024-04-22', '2024-05-05'),  -- De 22 de abril a 5 de maio
('Sprint 02', '2024-05-06', '2024-05-19'),  -- De 6 a 19 de maio
('Sprint 03', '2024-05-20', '2024-06-02'),  -- De 20 de maio a 2 de junho
('Sprint 04', '2024-06-03', '2024-07-21'),  -- De 3 a 21 de junho
('Sprint 05', '2024-07-22', '2024-08-04'),  -- De 22 de julho a 4 de agosto
('Sprint 06', '2024-08-05', '2024-08-18'),  -- De 5 a 18 de agosto
('Sprint 07', '2024-08-19', '2024-09-01'),  -- De 19 de agosto a 1 de setembro
('Sprint 08', '2024-09-02', '2024-09-22'),  -- De 2 a 22 de setembro
('Sprint 09', '2024-09-23', '2024-10-06'),  -- De 23 de setembro a 6 de outubro
('Sprint 10', '2024-10-07', '2024-10-20'),  -- De 7 a 20 de outubro
('Sprint 11', '2024-10-21', '2024-11-03'),  -- De 21 de outubro a 3 de novembro
('Sprint 12', '2024-11-04', '2024-11-17');  -- De 4 a 17 de novembro

-- Inserção de alocações (considerando que as IDs de atividades são 1 a 3 e períodos são 1 e 2)
INSERT INTO alocacoes (id_aluno, id_atividade, id_periodo) VALUES
(1, 1, 1),  -- João alocado na atividade 1 durante o Semestre 1
(2, 1, 2),  -- Maria alocada na atividade 1 durante o Semestre 2
(3, 2, 1),  -- Carlos alocado na atividade 2 durante o Semestre 1
(4, 3, 2),  -- Ana alocada na atividade 3 durante o Semestre 2
(5, 1, 1);  -- Pedro alocado na atividade 1 durante o Semestre 1

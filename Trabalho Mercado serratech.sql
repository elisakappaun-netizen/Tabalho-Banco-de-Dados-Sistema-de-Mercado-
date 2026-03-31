-- =========================
-- 1. CRIAR DATABASE
-- =========================
drop table categoria cascade; 
drop table estoque cascade; 
drop table historico_preco  cascade; 
drop table venda cascade; 
drop table item_venda  cascade; 
drop table produto cascade;


create database mecardo_dinamico;

-- =========================
-- 2. CRIAR TABLES
-- =========================

create table categoria(
	id_categoria serial primary key,
	nome_categoria varchar (100) not null, 
	descricao text 
);

create table produto (
	id_produto serial primary key ,
	nome_produto varchar(100) not null unique,
	descricao text,
	unidade char(2),   
	id_categoria int not null, 
	constraint fk_produto_categoria 
		foreign key (id_categoria) 
		references categoria(id_categoria)	
		on delete restrict
);

create table estoque (
id_estoque serial primary key,
	quantidade int not null default 0 check (quantidade >= 0) ,
	--evita quantidade null e ativ 2.3 
	estoque_minimo int not null,
	ultima_atualizacao timestamp default current_timestamp,
	--evita tempo null a ativ 2.3
	id_produto int not null unique,
	constraint fk_estoque_produto
	foreign key (id_produto)
	references produto(id_produto)
	on delete restrict
);

create table historico_preco(
id_historico serial primary key,
preco decimal(10, 2) not null check (preco > 0 ),
data_inicio timestamp default current_timestamp, 
motivo varchar(50),
id_produto int not null,
constraint fk_historico_produto
	foreign key (id_produto)
	references produto(id_produto)
	on delete restrict
);

create table venda (
	id_venda serial primary key,
	data_venda timestamp default current_timestamp,
	cliente varchar(100),
	total decimal (10,2) not null default 0
);

create table item_venda (    
	id_item serial primary key,
	quantidade int not null,
	preco_unitario decimal (10,2) not null,
	subtotal decimal (10,2) not null,
	id_venda int not null,
	constraint fk_item_venda 
		foreign key (id_venda)
		references venda(id_venda)
		on
	delete
		restrict,
		id_produto int not null,
		constraint fk_item_produto
		foreign key (id_produto)
		references produto(id_produto)
		on
		delete
			restrict,
			unique (id_venda,
			id_produto)
);

-- =========================
-- 3. INSERTS
-- =========================


INSERT INTO categoria (nome_categoria) VALUES
('Laticínios'),
('Bebidas'),
('Hortifruti'),
('Higiene');

INSERT INTO produto (nome_produto, unidade, id_categoria) VALUES
('Leite Integral 1L','UN',1),
('Queijo Mussarela','KG',1),
('Iogurte Natural','UN',1),
('Refrigerante Cola 2L','UN',2),
('Suco Laranja 1L','UN',2),
('Cerveja Lata','UN',2),
('Maçã','KG',3),
('Banana','KG',3),
('Alface','UN',3),
('Tomate','KG',3),
('Sabonete','UN',4),
('Shampoo','UN',4),
('Papel Higiênico','UN',4),
('Detergente','UN',4),
('Creme Dental','UN',4);


INSERT INTO estoque (id_produto, quantidade, estoque_minimo) VALUES
(1,50,10),
(2,20,10),
(3,8,10), -- produto a baixo de 10 (id = 3)
(4,60,15),
(5,40,10),
(6,12,10),
(7,25,10),
(8,9,10), -- produto a baixo de 10 (id = 8)
(9,5,10), -- produto a baixo de 10 (id = 9)
(10,30,10),
(11,70,20),
(12,15,10),
(13,18,10),
(14,22,10),
(15,6,10); -- produto a baixo de 10 (id = 15)

select * from estoque;
select * from produto;

-- insert inicial para o preco inicial
INSERT INTO historico_preco (id_produto, preco, motivo) VALUES
(1,4.50,'Inicial'),
(2,32,'Inicial'),
(3,6,'Inicial'),
(4,9,'Inicial'),
(5,7,'Inicial'),
(6,3.5,'Inicial'),
(7,5,'Inicial'),
(8,4,'Inicial'),
(9,3,'Inicial'),
(10,6,'Inicial'),
(11,2.5,'Inicial'),
(12,15,'Inicial'),
(13,18,'Inicial'),
(14,4,'Inicial'),
(15,6,'Inicial');

-- insert de ajuste de preço (GERENTE FICOU MALUCO)
INSERT INTO historico_preco (id_produto, preco, motivo) VALUES
(1,4.99,'Ajuste'),
(2,35,'Ajuste'),
(3,6.5,'Ajuste'),
(4,9.5,'Ajuste'),
(5,7.5,'Ajuste'),
(6,3.9,'Ajuste'),
(7,5.5,'Ajuste'),
(8,4.2,'Ajuste'),
(9,3.3,'Ajuste'),
(10,6.8,'Ajuste'),
(11,2.8,'Ajuste'),
(12,16,'Ajuste'),
(13,19,'Ajuste'),
(14,4.5,'Ajuste'),
(15,6.8,'Ajuste');

INSERT INTO venda (cliente,total) VALUES
('João Paulo',0),
('Maria Betânia',0),
('Pedro Paulo',0),
('Ana Julia',0),
('Lucas',0),
('Carlos',0),
('Julia',0),
('Fernanda',0),
('Rafael',0),
('Bruna',0);


-- VENDA 1
INSERT INTO item_venda (id_venda,id_produto,quantidade,preco_unitario,subtotal) VALUES
(1,1,2,4.99,9.98),
(1,4,1,9.50,9.50),
(2,2,1,35,35),
(2,7,2,5.50,11),
(3,3,3,6.90,19.80),
(4,5,2,7.50,15),
(5,6,6,3.90,23.40),
(6,8,3,4.60,13.80),
(7,9,2,3.45,6.90),
(8,10,1,6.80,6.80),
(9,12,1,16,16),
(10,15,2,6.90,13.80);

-- select feito para refletir a quantidade de venda feita por cada id_venda que funciona como "cadastro" (PASSAR PARA UMA VIEW)
select v.cliente,iv.subtotal,COUNT(iv.id_venda) as total from item_venda iv inner join venda v on iv.id_venda = v.id_venda group by v.cliente, iv.subtotal;

-- select para saber as vezes que o cliente foi ao mercado e o MERCADO realizou uma venda (PASSAR PARA UMA VIEW)
SELECT cliente, COUNT(total) AS total_visitas FROM venda WHERE cliente IS NOT null GROUP BY cliente ORDER BY total_visitas DESC;

-- select feito para saber o valor gasto por cada cliente "cadastrado" na tabela venda relacionando com o subtotal na item_venda (PASSAR PARA UMA VIEW)
SELECT v.cliente, SUM(iv.subtotal) AS total_gasto FROM venda v JOIN item_venda iv ON iv.id_venda = v.id_venda GROUP BY v.cliente ORDER BY total_gasto DESC;

select * from venda;
select * from item_venda;

-- inserindo mais um cliente pois ele foi fazer uma nova visita e o MERCADO fez uma nova venda
INSERT INTO venda (cliente,total) VALUES
('Eliza Samudio',0); -- inserindo com 0 pois é a primeira vez
INSERT INTO venda (cliente,total) VALUES
('Eliza Samudio',1); -- inserindo com 1 pois é a segunda vez

-- VENDA 2 relacionado ao id_cliente 11 pois a fk tem q ser relacionada para um id_venda nao existente nesse insert
INSERT INTO item_venda (id_venda,id_produto,quantidade,preco_unitario,subtotal) VALUES
(11,1,2,4.99,9.98),
(11,4,1,9.50,9.50),
(11,7,1,5.50,5.50);

-- VENDA 3 relacionado ao id_cliente 11 pois a fk tem q ser relacionada para um id_venda nao existente nesse insert
INSERT INTO item_venda (id_venda,id_produto,quantidade,preco_unitario,subtotal) VALUES
(12,2,1,35.00,35.00),
(12,7,2,5.50,11.00),
(12,3,1,6.50,6.50);


-- =========================
-- 4. LISTAS DE EXERCÍCIOS
-- =========================


--C1:

--Lista de Produtos com Categorias Retorne o nome de cada produto junto com o nome de sua categoria. 
--Ordene pelo nome da categoria e depois pelo nome do produto. Inclua todos os produtos, mesmo os sem categoria.
--Retornar: nome_produto, categoria, unidade

select
	p.nome_produto,
	c.nome_categoria as categoria,
	p.unidade
from
	produto p
left join categoria c on
	c.id_categoria = p.id_categoria
order by
	c.nome_categoria,
	p.nome_produto;


--C2:

--Estoque Atual de Todos os Produtos Mostre o nome de cada produto, sua quantidade em estoque e o estoque mínimo definido.
--Ordene pelos produtos com menor estoque primeiro.
--Retornar: nome_produto, quantidade_estoque, estoque_minimo

select
	p.nome_produto,
	e.quantidade as quantidade_estoque,
	e.estoque_minimo
from
	estoque e
inner join produto p on
	p.id_produto = e.id_estoque
order by
	e.quantidade asc;


--C3:

--Histórico Completo de Preços. Liste todos os registros de alteração de preço, 
--mostrando o nome do produto, o preço, a data de início e o motivo. 
--Ordene por produto e depois por data decrescente (mais recente primeiro).
--Retornar: nome_produto, preco, data_inicio, motivo

select
	p.nome_produto,
	hp.preco,
	hp.data_inicio,
	hp.motivo
from
	historico_preco hp
inner join produto p on
	p.id_produto = hp.id_produto
order by
	p.nome_produto,
	hp.data_inicio desc;


--C4:

--Preço Atual de Cada Produto Mostre o preço vigente de cada produto (o registro mais recente no histórico).
--Não inclua produtos sem histórico de preço.
--Retornar: nome_produto, preco_atual, data_vigencia

select
	p.nome_produto,
	hp.preco as preco_atual,
	hp.data_inicio as data_vigencia
from
	produto p
inner join historico_preco hp on
	hp.id_produto = p.id_produto
where
	hp.data_inicio = (
	select
		max(data_inicio)
	from
		historico_preco	
	
);


--C5:

--Total de Vendas por Período Mostre o total faturado em cada venda, com a data e o nome do cliente. 
--Inclua também a quantidade de itens diferentes em cada venda. Ordene pelas vendas mais recentes.
--Retornar: id_venda, data_venda, cliente, total_venda, qtd_itens

select
	v.id_venda,
	v.data_venda,
	v.cliente,
	sum(iv.subtotal) as total_venda,
	count(iv.quantidade) as qtd_itens
from
	venda v
inner join item_venda iv on
	iv.id_venda = v.id_venda
group by
	v.id_venda,
	v.data_venda,
	v.cliente
order by
	v.data_venda desc;


--C6: 

--Produto Mais Vendido
--Identifique quais produtos foram mais vendidos em termos de quantidade total de unidades. 
--Liste os 5 mais vendidos
--Retornar: nome_produto, categoria, total_unidades_vendidas

select
	p.nome_produto,
	c.nome_categoria,
	sum(iv.quantidade) as total_unidades
from
	item_venda iv
inner join produto p on
	iv.id_produto = p.id_produto
inner join categoria c on
	c.id_categoria = p.id_categoria
group by
	p.nome_produto,
	c.nome_categoria
order by
	total_unidades desc
limit 5;


inner join estoque e on p.id_produto = e.id_produto

--C7:

--Produtos com Estoque Crítico
--Liste os produtos cuja quantidade em estoque está abaixo do estoque mínimo definido. 
--Mostre também o preço atual de cada produto.
--Retornar: nome_produto, quantidade_atual, estoque_minimo, preco_atual

select
	p.nome_produto,
	e.quantidade as quantidade_atual,
	e.estoque_minimo,
	hp.preco as preco_atual
from
	produto p
inner join estoque e on
	 p.id_produto = e.id_produto
inner join historico_preco hp on
	hp.id_produto  = p.id_produto
where
	e.quantidade < e.estoque_minimo
	and hp.data_inicio = (
	select
		max(data_inicio)
	from
		historico_preco
);

-- C8:

-- Faturamento Total por Categoria
-- Calcule o total faturado com produtos de cada categoria, considerando todos os itens de venda.
--  Ordene pelo maior faturamento.
-- Retornar: categoria, faturamento_total, total_itens_vendidos


select
	c.nome_categoria as categoria,
	sum(iv.subtotal) as faturamento_total,
	sum(iv.quantidade) as total_itens_vendidos
from
	item_venda iv
inner join produto p on
	p.id_produto = iv.id_produto
inner join categoria c on
	c.id_categoria = p.id_categoria
group by
	c.nome_categoria
order by
	faturamento_total desc;


-- ==================================================
--  INÍCIO Desafio Final - Regra de Negócio Dinâmica 
-- ==================================================

-- 01 Identificar os Produtos Afetados
--Escreva uma consulta SELECT que liste todos os produtos cujo estoque atual é menor que 10 unidades. 
--A consulta deve retornar: nome do produto, quantidade em estoque e o preço atual (último registro no histórico).

select
	p.nome_produto,
	e.quantidade,
	hp.preco as preco_atual
from
	produto p
inner join estoque e on
	p.id_produto = e.id_produto
inner join historico_preco hp on
	hp.id_produto = p.id_produto
where
	quantidade < 10
	and hp.data_inicio = (
	select
		max(data_inicio)
	from
		historico_preco);

-- 02 Calcular o Novo Preço
--Para cada produto identificado, calcule o novo preço (preco_atual * 1.15). 
--Mostre esse cálculo na própria consulta SELECT antes de inserir, para visualizar o impacto antes de confirmar.


select
	p.nome_produto,
	e.quantidade,
	hp.preco as preco_atual,
	hp.preco * 1.15 as novo_preco
from
	produto p
inner join estoque e on
	p.id_produto = e.id_produto
inner join historico_preco hp on
	hp.id_produto = p.id_produto
where
	quantidade < 10
	and hp.data_inicio = (
	select
		max(data_inicio)
	from
		historico_preco);


--03 Registrar no Histórico de Preços
--Insira um novo registro na tabela HISTORICO_PRECO para cada produto afetado, contendo:
--O novo preço calculado
--data_inicio = momento atual (CURRENT_TIMESTAMP)
--*motivo = 'Ajuste automático: estoque crítico (< 10 unidades)'


insert
	into
	historico_preco (id_produto,
	preco,
	motivo)
select
	p.id_produto,
	hp.preco * 1.15,
	'Ajuste automático: estoque crítico (< 10 unidades)'
from
	produto p
inner join estoque e on
	p.id_produto = e.id_produto
inner join historico_preco hp on
	hp.id_produto = p.id_produto
where
	quantidade < 10
	and hp.data_inicio = (
	select
		max(data_inicio)
	from
		historico_preco);

select * from historico_preco;


--04 Validar a Alteração
--Execute novamente a consulta C4 (preço atual) e a consulta C7 (estoque crítico) para confirmar
--que os novos preços estão refletidos. Compare os valores antes e depois das inserções.

--C4 

select
	p.nome_produto,
	hp.preco as preco_atual,
	hp.data_inicio as data_vigencia
from
	produto p
inner join historico_preco hp on
	hp.id_produto = p.id_produto
where
	hp.data_inicio = (
	select
		max(data_inicio)
	from
		historico_preco	
);

--C7

select
	p.nome_produto,
	e.quantidade as quantidade_atual,
	e.estoque_minimo,
	hp.preco as preco_atual
from
	produto p
inner join estoque e on
	p.id_produto = e.id_estoque
inner join historico_preco hp on
	hp.id_produto  = p.id_produto
where
	e.quantidade < e.estoque_minimo
	and hp.data_inicio = (
	select
		max(data_inicio)
	from
		historico_preco
);

-- ===========================================
--  FIM
-- ===========================================



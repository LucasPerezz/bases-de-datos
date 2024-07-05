CREATE DATABASE wf1;
GO

USE wf1;
GO

CREATE SCHEMA practica;
GO

CREATE TABLE practica.Empleados (
EmpleadoID INT identity(1,1) primary key,
Nombre VARCHAR(50),
Departamento VARCHAR(50),
Salario DECIMAL(10, 2)
)
GO

INSERT INTO practica.Empleados (Nombre, Departamento, Salario)
VALUES
('Juan', 'Ventas', 3000.00),
('María', 'Ventas', 2800.00),
('Pedro', 'Marketing', 3200.00),
('Laura', 'Marketing', 3500.00),
('Carlos', 'IT', 4000.00);
GO

-- Ejercicio 1
SELECT *, DENSE_RANK() OVER(ORDER BY Salario DESC) AS OrdenEmpleadosSalario
FROM practica.Empleados
GO

-- Ejercicio 2
INSERT INTO practica.Empleados (Nombre, Departamento, Salario)
VALUES
('Ramiro', 'Ventas', 1800.00),
('Tomas', 'Ventas', 3200.00),
('Erik', 'Marketing', 1477.00),
('Esteban', 'Marketing', 15000.00),
('Laura', 'IT', 452.00),
('Romina', 'Ventas', 7855.00),
('Susana', 'Ventas', 1233.00),
('Mateo', 'Marketing', 4755.00),
('Nicolas', 'Marketing', 1236.00),
('Federico', 'IT', 260611.00),
('Miguel', 'Ventas', 4688.00),
('Josefina', 'Ventas', 2855.00),
('Franco', 'Marketing', 7456.00),
('Cesar', 'Marketing', 2555.00),
('Patricio', 'IT', 4000.00)
GO

SELECT *, RANK() OVER(PARTITION BY Departamento ORDER BY Salario DESC) AS Ranking
FROM practica.Empleados

-- Ejercicio 3

SELECT *, NTILE(4) OVER(ORDER BY Salario DESC) AS GrupoSalario
FROM practica.Empleados

-- Ejercicio 4

SELECT *, LAG(Salario, 1, 0) OVER(PARTITION BY Departamento ORDER BY Salario ASC) AS SalarioAnterior, LEAD(Salario, 1, 0) OVER (PARTITION BY Departamento ORDER BY Salario ASC) as SiguienteSalario
FROM practica.Empleados
GO

CREATE TABLE practica.Clientes(
id_cliente INT identity(1,1) PRIMARY KEY,
nombre VARCHAR(50),
pais VARCHAR(50),
)
GO

CREATE TABLE practica.Pedidos (
id_pedido INT PRIMARY KEY,
id_cliente INT,
fecha_pedido DATE,
monto DECIMAL(10, 2),
FOREIGN KEY (id_cliente) REFERENCES practica.Clientes(id_cliente)
)


INSERT INTO practica.Clientes (nombre, pais)
VALUES 
('John Doe', 'Argentina'),
('Jane Smith', 'Australia'),
('Juan García', 'Brasil'),
('Maria Hernandez', 'Canadá'),
('Michael Johnson', 'China'),
('Sophie Martin', 'Dinamarca'),
('Ahmad Khan', 'Egipto'),
('Emily Brown', 'Francia'),
('Hans Müller', 'Alemania'),
('Sofia Rossi', 'Italia'),
('Takeshi Yamada', 'Japón'),
('Javier López', 'México'), 
('Eva Novak', 'Países Bajos'),
('Rafael Silva', 'Portugal'), 
('Olga Petrova', 'Rusia'), 
('Fernanda Gonzalez', 'España'),
('Mohammed Ali', 'Egipto'),
('Lena Schmidt', 'Alemania'),
('Yuki Tanaka', 'Japón'), 
('Lucas Costa', 'Brasil');

DECLARE @startDate DATE = '2023-01-01';
DECLARE @endDate DATE = '2023-12-31';
DECLARE @orderId INT = 1;
WHILE @orderId <= 100
BEGIN
INSERT INTO practica.Pedidos (id_pedido,id_cliente, fecha_pedido, monto)
VALUES (
@orderId,
((@orderId - 1) % 20) + 1,
 DATEADD(DAY, ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, @startDate, @endDate) + 1),
@startDate),
 ROUND(RAND(CHECKSUM(NEWID())) * 5000 + 1000, 2)
);
SET @orderId = @orderId + 1;
END

SELECT *
FROM practica.Pedidos

SELECT *
FROM practica.Clientes

SELECT *
FROM practica.Empleados

-- Ejercicio 5
WITH CTE (pedido, cliente, monto) AS
(
	SELECT id_pedido, practica.Clientes.id_cliente, monto
	FROM practica.Pedidos
	JOIN practica.Clientes ON practica.Clientes.id_cliente = practica.Pedidos.id_cliente
	GROUP BY id_pedido, practica.Clientes.id_cliente, monto
)
SELECT *, AVG(monto) OVER(PARTITION BY cliente) as promedio_monto_cliente, DENSE_RANK() OVER(PARTITION BY cliente ORDER BY monto DESC) as posicion_rel_monto_cliente
FROM CTE


-- Ejercicio 6
WITH CTE (nombre, pais, monto) AS (
	SELECT nombre, pais, SUM(monto)
	FROM practica.Clientes
	JOIN practica.Pedidos ON practica.Clientes.id_cliente = practica.Pedidos.id_cliente
	GROUP BY nombre, pais
) 
SELECT *, RANK() OVER(PARTITION BY pais ORDER BY monto DESC) as ranking_por_pais
FROM CTE

-- Ejercicio 7
WITH CTE (pedido, cliente, fechaPedido, monto, siguienteMonto) as (
	SELECT practica.Pedidos.id_pedido, practica.Clientes.id_cliente, practica.Pedidos.fecha_pedido, practica.Pedidos.monto, LEAD(practica.Pedidos.monto, 1) OVER(ORDER BY practica.Clientes.id_cliente, practica.Pedidos.fecha_pedido ASC)
	FROM practica.Clientes
	JOIN practica.Pedidos ON practica.Clientes.id_cliente = practica.Pedidos.id_cliente
)
SELECT pedido, cliente, fechaPedido, monto, (monto - siguienteMonto) AS diferencia_monto
FROM CTE

-- Ejercicio 8
WITH CTE (pedido, cliente, pais, monto) as (
	SELECT practica.Pedidos.id_pedido, practica.Pedidos.id_cliente, practica.Clientes.pais, practica.Pedidos.monto
	FROM practica.Clientes
	JOIN practica.Pedidos ON practica.Clientes.id_cliente = practica.Pedidos.id_cliente
)
SELECT *, PERCENT_RANK() OVER(PARTITION BY pais ORDER BY monto ASC) as percentil_monto
FROM CTE

-- Ejercicio 9

SELECT  p.id_pedido, p.id_cliente, c.nombre AS nombre_cliente,
    COUNT(*) OVER (PARTITION BY p.id_cliente) AS total_pedidos_cliente,
    ROW_NUMBER() OVER (PARTITION BY p.id_cliente ORDER BY p.fecha_pedido) AS posicion_rel_pedidos_cliente
FROM practica.Pedidos p
JOIN practica.Clientes c ON p.id_cliente = c.id_cliente
ORDER BY p.id_cliente, p.fecha_pedido;
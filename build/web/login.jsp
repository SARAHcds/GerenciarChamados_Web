<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Entrar - Gerenciar Chamados</title>
    <link rel="stylesheet" href="css/estilo.css">
</head>
<body class="pagina-login">
<div class="cartao">
    <h1>Gerenciar Chamados</h1>
    <form method="post" action="loginProcessa.jsp">
        <label>E-mail
            <input type="email" name="email" required>
        </label>
        <label>Senha
            <input type="password" name="senha" required>
        </label>
        <button type="submit">Entrar</button>
    </form>
    <%
        String erro = request.getParameter("erro");
        if ("1".equals(erro)) {
    %>
        <p class="msg erro">E-mail ou senha inválidos, ou usuário inativo.</p>
    <% } else if ("2".equals(erro)) { %>
        <p class="msg erro">Não foi possível conectar ao banco de dados.</p>
    <% } %>
</div>
</body>
</html>

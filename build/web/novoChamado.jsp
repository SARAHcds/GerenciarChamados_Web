<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.ChamadoBean"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }
    if (usuario.isTI()) { response.sendRedirect("painel.jsp"); return; }

    String tituloPagina = "Novo chamado";
%>
<%@ include file="includes/topo.jspf" %>

<h2>Abrir novo chamado</h2>
<form method="post" action="chamadoSalvar.jsp" class="formulario">
    <label>Título
        <input type="text" name="titulo" maxlength="100" required>
    </label>
    <label>Descrição
        <textarea name="descricao" rows="5" required></textarea>
    </label>
    <label>Tipo
        <select name="tipo">
            <% for (String t : ChamadoBean.TIPOS) { %>
                <option value="<%= t %>"><%= t %></option>
            <% } %>
        </select>
    </label>
    <label>Categoria
        <select name="categoria">
            <% for (String cat : ChamadoBean.CATEGORIAS) { %>
                <option value="<%= cat %>"><%= cat %></option>
            <% } %>
        </select>
    </label>
    <label>Impacto (quanto o problema afeta o seu trabalho)
        <select name="impacto">
            <% for (String i : ChamadoBean.NIVEIS_IMPACTO) { %>
                <option value="<%= i %>"><%= i %></option>
            <% } %>
        </select>
    </label>
    <label>Urgência (quanto tempo você pode esperar)
        <select name="urgencia">
            <% for (String u : ChamadoBean.NIVEIS_URGENCIA) { %>
                <option value="<%= u %>"><%= u %></option>
            <% } %>
        </select>
    </label>
    <p class="ajuda">A prioridade e o prazo de atendimento (SLA) são calculados automaticamente.</p>
    <button type="submit" class="botao">Abrir chamado</button>
</form>

<%@ include file="includes/rodape.jspf" %>

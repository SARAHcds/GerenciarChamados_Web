<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="DAO.ChamadoDAO"%>
<%@page import="model.ChamadoBean"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }

    String tituloPagina = "Editar chamado";
    String erroPagina = null;
    ChamadoBean c = null;
    try {
        int id = Integer.parseInt(request.getParameter("id"));
        c = new ChamadoDAO().buscarPorId(id);
        if (c == null) {
            erroPagina = "Chamado não encontrado.";
        } else if (!usuario.isTI() && c.getIdUsuario() != usuario.getIdUsuario()) {
            c = null;
            erroPagina = "Você não tem acesso a este chamado.";
        } else if (ChamadoBean.STATUS_CONCLUIDO.equals(c.getStatus())) {
            erroPagina = "Chamado concluído não pode ser editado.";
            c = null;
        }
    } catch (Exception e) {
        erroPagina = "Chamado não encontrado.";
    }
%>
<%@ include file="includes/topo.jspf" %>

<% if (c == null) { %>
    <p class="msg erro"><%= erroPagina %></p>
    <a href="painel.jsp">Voltar ao painel</a>
<% } else { %>

<h2>Editar chamado nº <%= c.getIdChamado() %></h2>
<form method="post" action="chamadoAcao.jsp" class="formulario">
    <input type="hidden" name="acao" value="editar">
    <input type="hidden" name="id" value="<%= c.getIdChamado() %>">

    <label>Título
        <input type="text" name="titulo" maxlength="100" required value="<%= Texto.escapar(c.getTitulo()) %>">
    </label>
    <label>Descrição
        <textarea name="descricao" rows="5" required><%= Texto.escapar(c.getDescricao()) %></textarea>
    </label>
    <label>Tipo
        <select name="tipo">
            <% for (String t : ChamadoBean.TIPOS) { %>
                <option value="<%= t %>" <%= t.equals(c.getTipo()) ? "selected" : "" %>><%= t %></option>
            <% } %>
        </select>
    </label>
    <label>Categoria
        <select name="categoria">
            <% for (String cat : ChamadoBean.CATEGORIAS) { %>
                <option value="<%= cat %>" <%= cat.equals(c.getCategoria()) ? "selected" : "" %>><%= cat %></option>
            <% } %>
        </select>
    </label>
    <label>Impacto
        <select name="impacto">
            <% for (String i : ChamadoBean.NIVEIS_IMPACTO) { %>
                <option value="<%= i %>" <%= i.equals(c.getImpacto()) ? "selected" : "" %>><%= i %></option>
            <% } %>
        </select>
    </label>
    <label>Urgência
        <select name="urgencia">
            <% for (String u : ChamadoBean.NIVEIS_URGENCIA) { %>
                <option value="<%= u %>" <%= u.equals(c.getUrgencia()) ? "selected" : "" %>><%= u %></option>
            <% } %>
        </select>
    </label>
    <p class="ajuda">Ao salvar, a prioridade e o prazo (SLA) são recalculados.</p>
    <button type="submit" class="botao">Salvar alterações</button>
</form>
<p><a href="chamado.jsp?id=<%= c.getIdChamado() %>">Cancelar</a></p>

<% } %>

<%@ include file="includes/rodape.jspf" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="DAO.ChamadoDAO"%>
<%@page import="model.ChamadoBean"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }

    String tituloPagina = "Chamado";
    String sucesso = null;
    String erro = null;
    try {
        String titulo = Texto.limpar(request.getParameter("titulo"));
        String descricao = Texto.limpar(request.getParameter("descricao"));
        String tipo = request.getParameter("tipo");
        String categoria = request.getParameter("categoria");
        String impacto = request.getParameter("impacto");
        String urgencia = request.getParameter("urgencia");

        if (titulo.isEmpty() || titulo.length() > 100 || descricao.isEmpty()
                || !Texto.valorValido(ChamadoBean.TIPOS, tipo)
                || !Texto.valorValido(ChamadoBean.CATEGORIAS, categoria)
                || !Texto.valorValido(ChamadoBean.NIVEIS_IMPACTO, impacto)
                || !Texto.valorValido(ChamadoBean.NIVEIS_URGENCIA, urgencia)) {
            erro = "Preencha todos os campos corretamente.";
        } else {
            ChamadoBean c = new ChamadoBean();
            c.setTitulo(titulo);
            c.setDescricao(descricao);
            c.setTipo(tipo);
            c.setCategoria(categoria);
            c.setImpacto(impacto);
            c.setUrgencia(urgencia);
            c.setIdUsuario(usuario.getIdUsuario());
            if (new ChamadoDAO().inserir(c)) {
                sucesso = "Chamado aberto com sucesso. Acompanhe o andamento no painel.";
            } else {
                erro = "Não foi possível abrir o chamado.";
            }
        }
    } catch (Exception e) {
        erro = "Erro ao salvar o chamado. Verifique a conexão com o banco.";
    }
%>
<%@ include file="includes/topo.jspf" %>

<% if (sucesso != null) { %><p class="msg sucesso"><%= sucesso %></p><% } %>
<% if (erro != null) { %><p class="msg erro"><%= erro %></p><% } %>
<a href="painel.jsp">Voltar ao painel</a>

<%@ include file="includes/rodape.jspf" %>

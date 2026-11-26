<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="DAO.ChamadoDAO"%>
<%@page import="model.ChamadoBean"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }

    String tituloPagina = "Ação no chamado";
    String sucesso = null;
    String erro = null;
    String acao = request.getParameter("acao");
    int id = 0;
    boolean excluiu = false;
    try {
        id = Integer.parseInt(request.getParameter("id"));
        ChamadoDAO dao = new ChamadoDAO();
        ChamadoBean c = dao.buscarPorId(id);

        if (c == null) {
            erro = "Chamado não encontrado.";

        } else if ("assumir".equals(acao)) {
            if (!usuario.isTI()) {
                erro = "Somente a equipe de TI pode assumir chamados.";
            } else if (dao.assumir(id, usuario.getIdUsuario())) {
                sucesso = "Chamado assumido. Ele agora está em análise com você.";
            } else {
                erro = "Não foi possível assumir: o chamado já tem responsável ou não está aberto.";
            }

        } else if ("status".equals(acao)) {
            String novo = request.getParameter("novoStatus");
            if (!usuario.isTI() || c.getIdTecnico() != usuario.getIdUsuario()) {
                erro = "Apenas o técnico responsável pode alterar o status.";
            } else if (dao.alterarStatus(id, c.getStatus(), novo)) {
                sucesso = "Status alterado com sucesso.";
            } else {
                erro = "Essa mudança de status não é permitida.";
            }

        } else if ("concluir".equals(acao)) {
            String solucao = request.getParameter("solucao");
            if (!usuario.isTI() || c.getIdTecnico() != usuario.getIdUsuario()) {
                erro = "Apenas o técnico responsável pode concluir o chamado.";
            } else if (dao.concluir(id, usuario.getIdUsuario(), solucao)) {
                sucesso = "Chamado concluído. O solicitante já pode responder a pesquisa de satisfação.";
            } else {
                erro = "Informe o resumo da solução. O chamado também precisa estar em andamento.";
            }

        } else if ("excluir".equals(acao)) {
            if (dao.excluir(id, usuario)) {
                sucesso = "Chamado excluído.";
                excluiu = true;
            } else {
                erro = "Somente a equipe de TI pode excluir, e apenas chamados abertos.";
            }

        } else if ("editar".equals(acao)) {
            boolean dono = c.getIdUsuario() == usuario.getIdUsuario();
            if (!usuario.isTI() && !dono) {
                erro = "Você não pode editar este chamado.";
            } else if (ChamadoBean.STATUS_CONCLUIDO.equals(c.getStatus())) {
                erro = "Chamado concluído não pode ser editado.";
            } else {
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
                    ChamadoBean b = new ChamadoBean();
                    b.setIdChamado(id);
                    b.setTitulo(titulo);
                    b.setDescricao(descricao);
                    b.setTipo(tipo);
                    b.setCategoria(categoria);
                    b.setImpacto(impacto);
                    b.setUrgencia(urgencia);
                    if (dao.atualizar(b)) {
                        sucesso = "Chamado atualizado. Prioridade e SLA foram recalculados.";
                    } else {
                        erro = "Não foi possível salvar as alterações.";
                    }
                }
            }

        } else {
            erro = "Ação inválida.";
        }
    } catch (Exception e) {
        erro = "Erro ao processar a ação. Verifique a conexão com o banco.";
    }
%>
<%@ include file="includes/topo.jspf" %>

<% if (sucesso != null) { %><p class="msg sucesso"><%= sucesso %></p><% } %>
<% if (erro != null) { %><p class="msg erro"><%= erro %></p><% } %>

<% if (!excluiu) { %>
    <a href="chamado.jsp?id=<%= id %>">Voltar ao chamado</a> |
<% } %>
<a href="painel.jsp">Painel</a>

<%@ include file="includes/rodape.jspf" %>

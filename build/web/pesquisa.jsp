<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="DAO.ChamadoDAO"%>
<%@page import="DAO.PesquisaDAO"%>
<%@page import="model.ChamadoBean"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.PerguntasPesquisa"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }
    if (usuario.isTI()) { response.sendRedirect("painel.jsp"); return; }

    String tituloPagina = "Pesquisa de satisfação";
    String motivo = null;
    ChamadoBean c = null;
    try {
        int id = Integer.parseInt(request.getParameter("id"));
        c = new ChamadoDAO().buscarPorId(id);
        if (c == null) {
            motivo = "Chamado não encontrado.";
        } else if (c.getIdUsuario() != usuario.getIdUsuario()) {
            motivo = "Só o solicitante do chamado pode responder a pesquisa.";
        } else if (!ChamadoBean.STATUS_CONCLUIDO.equals(c.getStatus())) {
            motivo = "A pesquisa fica disponível quando o chamado for concluído.";
        } else if (new PesquisaDAO().jaRespondida(id)) {
            motivo = "Você já respondeu a pesquisa deste chamado.";
        }
    } catch (Exception e) {
        motivo = "Não foi possível abrir a pesquisa. Verifique a conexão com o banco.";
    }
    int total = PerguntasPesquisa.PERGUNTAS.length;
%>
<%@ include file="includes/topo.jspf" %>

<% if (motivo != null) { %>
    <p class="msg erro"><%= motivo %></p>
    <a href="painel.jsp">Voltar ao painel</a>
<% } else { %>

<script>document.documentElement.classList.add('js');</script>

<h2>Pesquisa de satisfação</h2>
<p class="ajuda">Chamado nº <%= c.getIdChamado() %> - <%= Texto.escapar(c.getTitulo()) %>.
    Escolha uma alternativa por pergunta (1, 2, 3 ou 4). O avanço é automático ao escolher.</p>

<div class="progresso"><div class="progresso-barra" id="progresso"></div></div>
<p class="contador" id="contador">Pergunta 1 de <%= total %></p>

<form method="post" action="pesquisaSalvar.jsp" id="formPesquisa">
    <input type="hidden" name="idChamado" value="<%= c.getIdChamado() %>">

    <% for (int q = 0; q < total; q++) { %>
        <fieldset class="passo">
            <legend><%= q + 1 %>. <%= PerguntasPesquisa.PERGUNTAS[q] %></legend>
            <% for (int op = 1; op <= 4; op++) { %>
                <label>
                    <input type="radio" name="q<%= q + 1 %>" value="<%= op %>" required class="resposta">
                    <%= op %> - <%= PerguntasPesquisa.OPCOES[op - 1] %>
                </label>
            <% } %>
            <p class="aviso">Escolha uma alternativa para continuar.</p>
        </fieldset>
    <% } %>

    <div class="passo-final" id="blocoFinal" style="display:none;">
        <label>Observação (opcional)
            <textarea name="observacao" maxlength="255"></textarea>
        </label>
    </div>

    <div class="navegacao">
        <button type="button" class="botao-sec" id="anterior">Anterior</button>
        <button type="button" class="botao" id="proxima">Próxima</button>
        <button type="submit" class="botao" id="enviar" style="display:none;">Enviar pesquisa</button>
    </div>
</form>

<script>
(function () {
    var passos = document.querySelectorAll('.passo');
    var atual = 0;
    var barra = document.getElementById('progresso');
    var contador = document.getElementById('contador');
    var btnAnt = document.getElementById('anterior');
    var btnProx = document.getElementById('proxima');
    var btnEnviar = document.getElementById('enviar');
    var blocoFinal = document.getElementById('blocoFinal');
    var ultimo = passos.length - 1;

    function respondido(i) {
        return passos[i].querySelector('input[type=radio]:checked') !== null;
    }

    function mostrar(i) {
        atual = i;
        for (var k = 0; k < passos.length; k++) {
            passos[k].classList.toggle('ativo', k === i);
        }
        barra.style.width = ((i + 1) / passos.length * 100) + '%';
        contador.textContent = 'Pergunta ' + (i + 1) + ' de ' + passos.length;
        btnAnt.style.visibility = i === 0 ? 'hidden' : 'visible';
        btnProx.style.display = i === ultimo ? 'none' : 'inline-block';
        btnEnviar.style.display = i === ultimo ? 'inline-block' : 'none';
        blocoFinal.style.display = i === ultimo ? 'block' : 'none';
    }

    btnProx.addEventListener('click', function () {
        if (!respondido(atual)) {
            passos[atual].querySelector('.aviso').style.display = 'block';
            return;
        }
        mostrar(atual + 1);
    });

    btnAnt.addEventListener('click', function () {
        if (atual > 0) { mostrar(atual - 1); }
    });

    // Ao escolher uma alternativa, avança sozinho depois de um instante
    document.querySelectorAll('.resposta').forEach(function (radio) {
        radio.addEventListener('change', function () {
            var passoAtual = atual;
            passos[passoAtual].querySelector('.aviso').style.display = 'none';
            setTimeout(function () {
                if (atual === passoAtual && passoAtual < ultimo) {
                    mostrar(passoAtual + 1);
                }
            }, 350);
        });
    });

    mostrar(0);
})();
</script>

<% } %>

<%@ include file="includes/rodape.jspf" %>

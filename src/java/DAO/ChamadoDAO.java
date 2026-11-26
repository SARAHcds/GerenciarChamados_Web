package DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import model.ChamadoBean;
import model.UsuarioBean;
import util.ConectaBD;

public class ChamadoDAO {

    private static final String SELECT_BASE =
        "SELECT c.*, s.nome AS nome_solicitante, t.nome AS nome_tecnico "
      + "FROM chamados c "
      + "JOIN usuario s ON c.id_usuario = s.id_usuario "
      + "LEFT JOIN usuario t ON c.id_tecnico = t.id_usuario ";

    // Abre um chamado. Prioridade e SLA são calculados aqui, não pela tela.
    public boolean inserir(ChamadoBean c) throws SQLException, ClassNotFoundException {
        String prioridade = ChamadoBean.calcularPrioridade(c.getImpacto(), c.getUrgencia());
        String sql = "INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, "
                   + "prioridade, status, sla_horas, id_usuario) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getTitulo());
            ps.setString(2, c.getDescricao());
            ps.setString(3, c.getTipo());
            ps.setString(4, c.getCategoria());
            ps.setString(5, c.getImpacto());
            ps.setString(6, c.getUrgencia());
            ps.setString(7, prioridade);
            ps.setString(8, ChamadoBean.STATUS_ABERTO);
            ps.setInt(9, ChamadoBean.slaPorPrioridade(prioridade));
            ps.setInt(10, c.getIdUsuario());
            return ps.executeUpdate() > 0;
        }
    }

    // Solicitante: só os chamados que ele abriu
    public List<ChamadoBean> listarDoSolicitante(int idUsuario) throws SQLException, ClassNotFoundException {
        return listar("WHERE c.id_usuario = ?", idUsuario);
    }

    // TI: todos os chamados que ainda não foram concluídos
    public List<ChamadoBean> listarAbertos() throws SQLException, ClassNotFoundException {
        return listar("WHERE c.status <> ?", ChamadoBean.STATUS_CONCLUIDO);
    }

    // TI: chamados abertos que ainda não têm técnico responsável
    public List<ChamadoBean> listarSemResponsavel() throws SQLException, ClassNotFoundException {
        return listar("WHERE c.id_tecnico IS NULL AND c.status <> ?", ChamadoBean.STATUS_CONCLUIDO);
    }

    // TI: chamados atribuídos a este técnico
    public List<ChamadoBean> listarDoTecnico(int idTecnico) throws SQLException, ClassNotFoundException {
        return listar("WHERE c.id_tecnico = ?", idTecnico);
    }

    public ChamadoBean buscarPorId(int idChamado) throws SQLException, ClassNotFoundException {
        String sql = SELECT_BASE + "WHERE c.id_chamado = ?";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idChamado);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? montar(rs) : null;
            }
        }
    }

    // Edita o chamado. Não altera chamado concluído.
    public boolean atualizar(ChamadoBean c) throws SQLException, ClassNotFoundException {
        String prioridade = ChamadoBean.calcularPrioridade(c.getImpacto(), c.getUrgencia());
        String sql = "UPDATE chamados SET titulo=?, descricao=?, tipo=?, categoria=?, impacto=?, urgencia=?, "
                   + "prioridade=?, sla_horas=? WHERE id_chamado=? AND status <> ?";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getTitulo());
            ps.setString(2, c.getDescricao());
            ps.setString(3, c.getTipo());
            ps.setString(4, c.getCategoria());
            ps.setString(5, c.getImpacto());
            ps.setString(6, c.getUrgencia());
            ps.setString(7, prioridade);
            ps.setInt(8, ChamadoBean.slaPorPrioridade(prioridade));
            ps.setInt(9, c.getIdChamado());
            ps.setString(10, ChamadoBean.STATUS_CONCLUIDO);
            return ps.executeUpdate() > 0;
        }
    }

    // Técnico assume um chamado aberto e sem responsável
    public boolean assumir(int idChamado, int idTecnico) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE chamados SET id_tecnico = ?, status = ? "
                   + "WHERE id_chamado = ? AND id_tecnico IS NULL AND status = ?";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idTecnico);
            ps.setString(2, ChamadoBean.STATUS_EM_ANALISE);
            ps.setInt(3, idChamado);
            ps.setString(4, ChamadoBean.STATUS_ABERTO);
            return ps.executeUpdate() > 0;
        }
    }

    // Muda o status seguindo o fluxo de ChamadoBean.transicaoPermitida
    public boolean alterarStatus(int idChamado, String atual, String novo) throws SQLException, ClassNotFoundException {
        if (!ChamadoBean.transicaoPermitida(atual, novo)) {
            return false;
        }
        String sql = "UPDATE chamados SET status = ? WHERE id_chamado = ? AND status = ?";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, novo);
            ps.setInt(2, idChamado);
            ps.setString(3, atual);
            return ps.executeUpdate() > 0;
        }
    }

    // Conclui o chamado. Exige técnico responsável, status "Em andamento" e solução preenchida.
    public boolean concluir(int idChamado, int idTecnico, String solucao) throws SQLException, ClassNotFoundException {
        if (solucao == null || solucao.trim().isEmpty()) {
            return false;
        }
        String sql = "UPDATE chamados SET status = ?, solucao_resumo = ?, data_conclusao = NOW() "
                   + "WHERE id_chamado = ? AND id_tecnico = ? AND status = ?";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, ChamadoBean.STATUS_CONCLUIDO);
            ps.setString(2, solucao.trim());
            ps.setInt(3, idChamado);
            ps.setInt(4, idTecnico);
            ps.setString(5, ChamadoBean.STATUS_EM_ANDAMENTO);
            return ps.executeUpdate() > 0;
        }
    }

    // Exclusão: só a equipe de TI, e só chamado "Aberto" (concluídos ficam para os relatórios)
    public boolean excluir(int idChamado, UsuarioBean usuario) throws SQLException, ClassNotFoundException {
        if (usuario == null || !usuario.isTI()) {
            return false;
        }
        String sql = "DELETE FROM chamados WHERE id_chamado = ? AND status = ?";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idChamado);
            ps.setString(2, ChamadoBean.STATUS_ABERTO);
            return ps.executeUpdate() > 0;
        }
    }

    private List<ChamadoBean> listar(String where, Object... parametros) throws SQLException, ClassNotFoundException {
        List<ChamadoBean> lista = new ArrayList<>();
        String sql = SELECT_BASE + where + " ORDER BY c.prioridade, c.data_abertura";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < parametros.length; i++) {
                ps.setObject(i + 1, parametros[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(montar(rs));
                }
            }
        }
        return lista;
    }

    private ChamadoBean montar(ResultSet rs) throws SQLException {
        ChamadoBean c = new ChamadoBean();
        c.setIdChamado(rs.getInt("id_chamado"));
        c.setTitulo(rs.getString("titulo"));
        c.setDescricao(rs.getString("descricao"));
        c.setTipo(rs.getString("tipo"));
        c.setCategoria(rs.getString("categoria"));
        c.setImpacto(rs.getString("impacto"));
        c.setUrgencia(rs.getString("urgencia"));
        c.setPrioridade(rs.getString("prioridade"));
        c.setStatus(rs.getString("status"));
        c.setSlaHoras(rs.getInt("sla_horas"));
        c.setDataAbertura(rs.getTimestamp("data_abertura"));
        c.setDataAtualizacao(rs.getTimestamp("data_atualizacao"));
        c.setDataConclusao(rs.getTimestamp("data_conclusao"));
        c.setSolucaoResumo(rs.getString("solucao_resumo"));
        c.setObservacao(rs.getString("observacao"));
        c.setIdUsuario(rs.getInt("id_usuario"));
        c.setIdTecnico(rs.getInt("id_tecnico")); // NULL vira 0
        c.setNomeSolicitante(rs.getString("nome_solicitante"));
        c.setNomeTecnico(rs.getString("nome_tecnico"));
        return c;
    }
}

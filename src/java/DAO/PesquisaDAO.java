package DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.List;
import model.PesquisaBean;
import util.ConectaBD;

public class PesquisaDAO {

    public boolean inserir(PesquisaBean p) throws SQLException, ClassNotFoundException {
        validarRespostas(p);
        String sql = "INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, q1, q2, q3, q4, q5, q6, q7, q8, observacao) "
                   + "SELECT c.id_chamado, c.id_usuario, c.id_tecnico, ?,?,?,?,?,?,?,?,? "
                   + "FROM chamados c WHERE c.id_chamado = ? AND c.id_usuario = ? AND c.status = 'Concluído'";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, p.getQ1());
            ps.setInt(2, p.getQ2());
            ps.setInt(3, p.getQ3());
            ps.setInt(4, p.getQ4());
            ps.setInt(5, p.getQ5());
            ps.setInt(6, p.getQ6());
            ps.setInt(7, p.getQ7());
            ps.setInt(8, p.getQ8());
            ps.setString(9, p.getObservacao());
            ps.setInt(10, p.getIdChamado());
            ps.setInt(11, p.getIdUsuario());
            return ps.executeUpdate() > 0;
        } catch (SQLIntegrityConstraintViolationException e) {
            return false; // chamado já foi respondido
        }
    }

    public boolean jaRespondida(int idChamado) throws SQLException, ClassNotFoundException {
        try (Connection con = ConectaBD.conectar();
             PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM pesquisa WHERE id_chamado = ?")) {
            ps.setInt(1, idChamado);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    // Relatório 1: cada entrevistado e suas respostas
    public List<PesquisaBean> relatorioPorUsuario() throws SQLException, ClassNotFoundException {
        List<PesquisaBean> lista = new ArrayList<>();
        String sql = "SELECT p.*, u.nome AS nome_usuario, c.titulo AS titulo_chamado "
                   + "FROM pesquisa p "
                   + "JOIN usuario u ON p.id_usuario = u.id_usuario "
                   + "JOIN chamados c ON p.id_chamado = c.id_chamado "
                   + "ORDER BY u.nome, p.data_resposta";
        try (Connection con = ConectaBD.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(montar(rs));
            }
        }
        return lista;
    }

    // Relatório 2: número de entrevistados
    public int totalEntrevistados() throws SQLException, ClassNotFoundException {
        try (Connection con = ConectaBD.conectar();
             PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM pesquisa");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public double[] percentuaisDaQuestao(int questao) throws SQLException, ClassNotFoundException {
        if (questao < 1 || questao > 8) {
            throw new IllegalArgumentException("Questão inválida: " + questao);
        }
        String col = "q" + questao; // seguro: vem de um inteiro validado acima
        String sql = "SELECT COUNT(*), "
                   + "SUM(" + col + " = 1), SUM(" + col + " = 2), SUM(" + col + " = 3), SUM(" + col + " = 4) "
                   + "FROM pesquisa";
        double[] pct = new double[4];
        try (Connection con = ConectaBD.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int total = rs.getInt(1);
                if (total > 0) {
                    for (int op = 0; op < 4; op++) {
                        pct[op] = rs.getInt(op + 2) * 100.0 / total;
                    }
                }
            }
        }
        return pct;
    }

    private void validarRespostas(PesquisaBean p) {
        int[] respostas = {p.getQ1(), p.getQ2(), p.getQ3(), p.getQ4(),
                           p.getQ5(), p.getQ6(), p.getQ7(), p.getQ8()};
        for (int r : respostas) {
            if (r < 1 || r > 4) {
                throw new IllegalArgumentException("Cada resposta deve ser 1, 2, 3 ou 4.");
            }
        }
    }

    private PesquisaBean montar(ResultSet rs) throws SQLException {
        PesquisaBean p = new PesquisaBean();
        p.setIdPesquisa(rs.getInt("id_pesquisa"));
        p.setIdChamado(rs.getInt("id_chamado"));
        p.setIdUsuario(rs.getInt("id_usuario"));
        p.setIdTecnico(rs.getInt("id_tecnico"));
        p.setDataResposta(rs.getTimestamp("data_resposta"));
        p.setQ1(rs.getInt("q1"));
        p.setQ2(rs.getInt("q2"));
        p.setQ3(rs.getInt("q3"));
        p.setQ4(rs.getInt("q4"));
        p.setQ5(rs.getInt("q5"));
        p.setQ6(rs.getInt("q6"));
        p.setQ7(rs.getInt("q7"));
        p.setQ8(rs.getInt("q8"));
        p.setObservacao(rs.getString("observacao"));
        p.setNomeUsuario(rs.getString("nome_usuario"));
        p.setTituloChamado(rs.getString("titulo_chamado"));
        return p;
    }
}

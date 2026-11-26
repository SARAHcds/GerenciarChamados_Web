package DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.UsuarioBean;
import util.ConectaBD;

public class UsuarioDAO {

    // Login: retorna o usuário se e-mail e senha conferirem e o cadastro estiver ativo; senão null
    public UsuarioBean autenticar(String email, String senha) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM usuario WHERE email = ? AND senha = ? AND ativo = TRUE";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, senha);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    UsuarioBean u = montar(rs);
                    registrarAcesso(con, u.getIdUsuario());
                    return u;
                }
            }
        }
        return null;
    }

    private void registrarAcesso(Connection con, int idUsuario) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("UPDATE usuario SET ultimo_acesso = NOW() WHERE id_usuario = ?")) {
            ps.setInt(1, idUsuario);
            ps.executeUpdate();
        }
    }

    public UsuarioBean buscarPorId(int idUsuario) throws SQLException, ClassNotFoundException {
        try (Connection con = ConectaBD.conectar();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM usuario WHERE id_usuario = ?")) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? montar(rs) : null;
            }
        }
    }

    // Técnicos ativos, para o campo de atribuição de chamado
    public List<UsuarioBean> listarTecnicos() throws SQLException, ClassNotFoundException {
        List<UsuarioBean> lista = new ArrayList<>();
        String sql = "SELECT * FROM usuario WHERE perfil = ? AND ativo = TRUE ORDER BY nome";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, UsuarioBean.PERFIL_TI);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(montar(rs));
                }
            }
        }
        return lista;
    }

    public boolean inserir(UsuarioBean u) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO usuario (nome, email, senha, perfil, matricula, setor, cargo, telefone, especialidade) "
                   + "VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection con = ConectaBD.conectar(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getNome());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getSenha());
            ps.setString(4, u.getPerfil());
            ps.setString(5, u.getMatricula());
            ps.setString(6, u.getSetor());
            ps.setString(7, u.getCargo());
            ps.setString(8, u.getTelefone());
            ps.setString(9, u.getEspecialidade());
            return ps.executeUpdate() > 0;
        }
    }

    private UsuarioBean montar(ResultSet rs) throws SQLException {
        UsuarioBean u = new UsuarioBean();
        u.setIdUsuario(rs.getInt("id_usuario"));
        u.setNome(rs.getString("nome"));
        u.setEmail(rs.getString("email"));
        u.setSenha(rs.getString("senha"));
        u.setPerfil(rs.getString("perfil"));
        u.setMatricula(rs.getString("matricula"));
        u.setSetor(rs.getString("setor"));
        u.setCargo(rs.getString("cargo"));
        u.setTelefone(rs.getString("telefone"));
        u.setEspecialidade(rs.getString("especialidade"));
        u.setAtivo(rs.getBoolean("ativo"));
        u.setDataCadastro(rs.getTimestamp("data_cadastro"));
        u.setDataAtualizacao(rs.getTimestamp("data_atualizacao"));
        u.setUltimoAcesso(rs.getTimestamp("ultimo_acesso"));
        return u;
    }
}

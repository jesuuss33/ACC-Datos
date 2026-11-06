import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Conexión a la BBDD clase_dam (PostgreSQL) mediante JDBC.
 * Requiere el driver postgresql en el classpath (postgresql-XX.jar o dependencia Maven).
 */
public class BBDD_JDBC_JV_1 {

    // Cambia estos datos por los de tu instalación
    private static final String URL = "jdbc:postgresql://localhost:5432/clase_dam";
    private static final String USUARIO = "postgres";
    private static final String PASSWORD = "tu_contraseña";

    public static void main(String[] args) {
        // try-with-resources: cierra la conexión automáticamente
        try (Connection conexion = DriverManager.getConnection(URL, USUARIO, PASSWORD)) {

            System.out.println("Conexión establecida con: "
                    + conexion.getMetaData().getDatabaseProductName()
                    + " " + conexion.getMetaData().getDatabaseProductVersion());

            mostrarAsignaturas(conexion);
            mostrarAlumnos(conexion, "2DAM");
            mostrarHorarioDia(conexion, "Lunes");
            mostrarNotaMedia(conexion);

        } catch (SQLException e) {
            System.err.println("Error de conexión o consulta: " + e.getMessage());
        }
    }

    // Asignaturas con su profesor
    private static void mostrarAsignaturas(Connection con) throws SQLException {
        String sql = "SELECT a.codigo, a.nombre, p.nombre AS profesor "
                + "FROM asignaturas a JOIN profesores p ON p.id = a.profesor_id "
                + "ORDER BY a.codigo";

        System.out.println("\n=== Asignaturas y profesores ===");
        try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                System.out.printf("%-7s | %-55s | %s%n",
                        rs.getString("codigo"), rs.getString("nombre"), rs.getString("profesor"));
            }
        }
    }

    // Alumnos de un grupo (consulta con parámetro)
    private static void mostrarAlumnos(Connection con, String grupo) throws SQLException {
        String sql = "SELECT al.nombre, al.apellidos, al.email "
                + "FROM alumnos al JOIN grupos g ON g.id = al.grupo_id "
                + "WHERE g.nombre = ? ORDER BY al.apellidos";

        System.out.println("\n=== Alumnos de " + grupo + " ===");
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, grupo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.printf("%s %s (%s)%n",
                            rs.getString("nombre"), rs.getString("apellidos"), rs.getString("email"));
                }
            }
        }
    }

    // Horario de un día
    private static void mostrarHorarioDia(Connection con, String dia) throws SQLException {
        String sql = "SELECT h.hora_inicio, h.hora_fin, a.nombre, p.nombre AS profesor "
                + "FROM horarios h "
                + "JOIN asignaturas a ON a.id = h.asignatura_id "
                + "JOIN profesores p ON p.id = a.profesor_id "
                + "WHERE h.dia_semana = ? ORDER BY h.hora_inicio";

        System.out.println("\n=== Horario del " + dia + " ===");
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, dia);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.printf("%s - %s | %s (%s)%n",
                            rs.getTime("hora_inicio"), rs.getTime("hora_fin"),
                            rs.getString("nombre"), rs.getString("profesor"));
                }
            }
        }
    }

    // Nota media por asignatura
    private static void mostrarNotaMedia(Connection con) throws SQLException {
        String sql = "SELECT a.nombre, ROUND(AVG(m.nota), 2) AS media "
                + "FROM matriculas m JOIN asignaturas a ON a.id = m.asignatura_id "
                + "GROUP BY a.nombre ORDER BY media DESC";

        System.out.println("\n=== Nota media por asignatura ===");
        try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                System.out.printf("%-55s | %.2f%n", rs.getString("nombre"), rs.getDouble("media"));
            }
        }
    }
}
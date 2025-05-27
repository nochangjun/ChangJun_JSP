package project;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/project/admin/deleteReport")
public class DeleteReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    public DeleteReportServlet() {
        super();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processDelete(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processDelete(request, response);
    }
    
    private void processDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain; charset=UTF-8");
        try {
            int reportId = Integer.parseInt(request.getParameter("report_id"));
            ReportMgr mgr = new ReportMgr();
            boolean result = mgr.deleteReport(reportId);
            if(result) {
                response.getWriter().print("success");
            } else {
                response.getWriter().print("fail");
            }
        } catch(Exception e) {
            e.printStackTrace();
            response.getWriter().print("fail");
        }
    }
}

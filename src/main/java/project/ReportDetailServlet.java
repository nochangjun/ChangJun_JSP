package project;

import java.io.IOException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/admin/ReportDetailServlet")
public class ReportDetailServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
         throws ServletException, IOException {
         
        // 신고 ID 파라미터 확인
        String reportIdParam = request.getParameter("report_id");
        if (reportIdParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "신고 ID가 없습니다.");
            return;
        }
        
        int reportId = 0;
        try {
            reportId = Integer.parseInt(reportIdParam);
        } catch(Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 신고 ID입니다.");
            return;
        }
        
        // ReportMgr을 통해 신고 상세 정보 조회
        ReportMgr mgr = new ReportMgr();
        ReportBean report = mgr.getReportDetail(reportId);
        if (report == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "신고 정보를 찾을 수 없습니다.");
            return;
        }
        
        // 조회된 신고 정보를 request에 저장 후 신고 상세보기 JSP로 포워딩
        request.setAttribute("report", report);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/project/admin/admin_Report_Detail.jsp");
        dispatcher.forward(request, response);
    }
}

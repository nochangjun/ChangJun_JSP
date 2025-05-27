package project;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/project/admin/reportProcess.do")
public class ReportProcessServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain; charset=UTF-8");  // 응답 타입과 인코딩 설정
        response.setCharacterEncoding("UTF-8");

        String reportIdStr = request.getParameter("report_id");
        String action = request.getParameter("action");

        if (reportIdStr == null || action == null || !action.equals("process")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 요청");
            return;
        }

        try {
            int reportId = Integer.parseInt(reportIdStr);
            ReportMgr reportMgr = new ReportMgr();

            // 신고 처리를 진행 (신고 상태를 '완료'로 업데이트하고 제한을 적용함)
            boolean processResult = reportMgr.processReport(reportId);

            if (processResult) {
                // 신고 상세 정보 조회 (신고된 대상의 종류와 타겟 ID, 신고당한 회원 ID 필요)
                ReportBean report = reportMgr.getReportDetail(reportId);
                if (report != null) {
                    String reportType = report.getReport_type();
                    int targetId = report.getReport_target_id();
                    String reportedMemberId = report.getReported_member_id();
                    boolean deletionResult = false;

                    // 신고된 내용에 따라 삭제 처리
                    if ("board".equals(reportType)) {
                        // 게시글 삭제 (BoardMgr.deleteBoard 메서드가 targetId를 이용하여 게시글 삭제)
                        BoardMgr boardMgr = new BoardMgr();
                        deletionResult = boardMgr.admindeleteBoard(targetId);
                    } else if ("comment".equals(reportType)) {
                        // 댓글 삭제 (CommentMgr.deleteComment 메서드가 targetId를 이용하여 댓글 삭제)
                        CommentMgr commentMgr = new CommentMgr();
                        deletionResult = commentMgr.deleteComment(targetId);
                    } else if ("review".equals(reportType)) {
                        // 리뷰 삭제 (ReviewMgr.deleteReview 메서드가 targetId를 이용하여 리뷰 삭제)
                        ReviewMgr reviewMgr = new ReviewMgr();
                        deletionResult = reviewMgr.deleteReview(targetId);
                    }
                    System.out.println("Content deletion result: " + deletionResult);

                    // 신고당한 회원에 대한 작성 제한 적용
                    MemberMgr memberMgr = new MemberMgr();
                    memberMgr.applyRestrictions(reportedMemberId);
                }
                
                // 처리 완료 메시지 출력 후 팝업 자동으로 닫기
                response.setContentType("text/html; charset=UTF-8");
                response.getWriter().write("<script>");
                response.getWriter().write("alert('신고 처리 완료');");
                response.getWriter().write("window.close();"); // 팝업 닫기
                response.getWriter().write("</script>");
            } else {
                response.getWriter().write("신고 처리 실패");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "서버 오류");
        }
    }
}

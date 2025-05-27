package project;

import project.InquiryMgr;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/admin/inquiryReply.do")
public class InquiryReplyServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        int inqId = Integer.parseInt(request.getParameter("inq_id"));
        String reply = request.getParameter("reply");
        String adminId = (String) request.getSession().getAttribute("admin_id");

        // ✅ 답변 내용이 비었는지 체크
        if (reply == null || reply.trim().isEmpty()) {
            PrintWriter out = response.getWriter();
            out.println("<script>");
            out.println("alert('답변 내용을 입력해주세요.');");
            out.println("history.back();");
            out.println("</script>");
            return;
        }

        InquiryMgr mgr = new InquiryMgr();
        mgr.addInquiryReply(inqId, reply, adminId); // 댓글 저장 + 상태 완료

        // 팝업 닫고 부모창 새로고침
        PrintWriter out = response.getWriter();
        out.println("<script>");
        out.println("window.opener.location.reload();");
        out.println("window.close();");
        out.println("</script>");
    }
}


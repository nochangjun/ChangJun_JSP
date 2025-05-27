package project;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/project/admin/eventWinnerRegister")
public class EvtWinnerRegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String adminId = (String) session.getAttribute("admin_id");

        if (adminId == null) {
            response.sendRedirect("../login/login.jsp");
            return;
        }

        String title = request.getParameter("title");
        String content = request.getParameter("content");

        System.out.println("📥 당첨자 등록 요청:");
        System.out.println("title = " + title);
        System.out.println("content = " + content);
        System.out.println("admin_id = " + adminId);

        EvtParticipantsBean bean = new EvtParticipantsBean();
        bean.setEvt_title(title);
        bean.setEvt_content(content);
        bean.setAdmin_id(adminId);

        EvtParticipantsMgr mgr = new EvtParticipantsMgr();
        boolean result = mgr.insertWinner(bean);

        if (result) {
            System.out.println("✅ 당첨자 등록 성공");
            response.sendRedirect("admin_Event_Participants.jsp?result=success");
        } else {
            System.out.println("❌ 당첨자 등록 실패");
            response.sendRedirect("admin_Event_Participants.jsp?result=fail");
        }
    }
}

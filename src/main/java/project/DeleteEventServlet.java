package project;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/project/admin/deleteEvent")
public class DeleteEventServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("id");  // 🔄 여기 'event_id' → 'id'
        String type = request.getParameter("type"); // "event" or "winner"
        boolean success = false;

        if (idStr != null && type != null) {
            int eventId = Integer.parseInt(idStr);

            if ("event".equals(type)) {
                EventMgr mgr = new EventMgr();
                success = mgr.deleteEvent(eventId);
            } else if ("winner".equals(type)) {
                EvtParticipantsMgr mgr = new EvtParticipantsMgr();
                success = mgr.deleteWinner(eventId);
            }
        }

        if (success) {
            response.sendRedirect("admin_Event_Delete.jsp?result=delete_success");
        } else {
            response.sendRedirect("admin_Event_Delete.jsp?result=delete_fail");
        }
    }
}

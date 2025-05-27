package project;

import java.io.BufferedReader;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

@WebServlet("/project/login/NaverLoginServlet")
public class NaverLoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setCharacterEncoding("UTF-8");
	    response.setContentType("application/json");

	    BufferedReader reader = request.getReader();
	    Gson gson = new Gson();
	    JsonObject data = gson.fromJson(reader, JsonObject.class);
	    System.out.println("Received JSON: " + data.toString());
	    
	    String email = data.get("email").getAsString();
	    String nickname = data.get("nickname").getAsString();
	    String profileImage = data.get("profileImage").getAsString();

	    // DB에서 이메일 존재 여부 체크 및 회원가입/로그인 처리
	    MemberMgr mgr = new MemberMgr();
	    MemberBean member = mgr.getMemberByEmail(email); // 이메일로 회원 조회 메서드 필요

	    if (member == null) {
	      // 신규회원이라면 DB에 회원 등록 처리
	    	MemberBean newMember = new MemberBean();
	    	newMember.setMember_id(email);                 // 이메일을 아이디로 사용 (VARCHAR(50))
	    	newMember.setMember_pwd("");                   // SNS 로그인은 비밀번호 별도 처리 (빈 문자열)
	    	newMember.setMember_name((nickname != null && !nickname.isEmpty()) ? nickname : email);  
	    	                                              // member_name은 nickname이 있으면 사용, 없으면 email로 대체 (VARCHAR(100))
	    	newMember.setMember_phone("000-0000-0000");      // 전화번호가 없으므로 기본값을 설정 (VARCHAR(20))
	    	newMember.setMember_email(email);              // 이메일 (VARCHAR(255))
	    	newMember.setMember_nickname(nickname);        // 닉네임 (VARCHAR(100))
	    	newMember.setMember_image(profileImage);       // 프로필 이미지 (VARCHAR(255), NULL 허용)
	      boolean insertResult = mgr.insertMember(newMember);

	      if (!insertResult) {
	        response.getWriter().write("{\"success\":false}");
	        return;
	      }
	    }

	    // 로그인 성공 후 세션 생성
	    HttpSession session = request.getSession();
	    session.setAttribute("idKey", email);  // 세션에 이메일 저장(아이디)

	    response.getWriter().write("{\"success\":true}");
	}

}

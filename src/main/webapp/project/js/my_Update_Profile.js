// 페이지 로드시 저장된 데이터 불러오기
window.onload = function () {
    setupSidebarNavigation(); // 사이드바 먼저 설정
	setupImagePreview();
};

// 이미지 업로드 버튼 클릭 시 파일 업로드 트리거
function setupImagePreview() {
    const uploadBtn = document.getElementById("imageUploadBtn");
    const fileInput = document.getElementById("imageFile");
    const preview = document.getElementById("preview");
    const defaultPreview = document.getElementById("default-preview");
    const resetBtn = document.getElementById("resetToDefaultBtn");
    const resetImageFlag = document.getElementById("resetImageFlag");
    
    if (uploadBtn && fileInput && preview && defaultPreview) {
        uploadBtn.addEventListener("click", function () {
            fileInput.click();
        });

        fileInput.addEventListener("change", function (event) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function (e) {
                    preview.src = e.target.result;
                    preview.style.display = "block";
                    defaultPreview.style.display = "none";
                };
                reader.readAsDataURL(file);
                
             	// 이미지 업로드가 있으면 초기화 플래그 false
                if (resetImageFlag) resetImageFlag.value = "false";
            }
        });
    }
    
 	// 기본 이미지로 변경 버튼 클릭 시
    if (resetBtn && preview && resetImageFlag) {
        resetBtn.addEventListener("click", function () {
            const defaultImgPath = contextPath + "/project/img/구머링.png";
            preview.src = defaultImgPath;
            preview.style.display = "block";
            defaultPreview.style.display = "none";
            fileInput.value = "";
            
         	// 서버로 기본 이미지로 변경 요청 전송
            resetImageFlag.value = "true";
        });
    }
};

// 사이드바 메뉴 클릭 설정
function setupSidebarNavigation() {
    const menuItems = document.querySelectorAll('.sidebar li');
    menuItems.forEach(function (item, index) {
        item.addEventListener('click', function () {
			if (item.textContent.includes('개인정보변경')) {
            	window.location.href = 'my_Update_Profile.jsp'; // 현재 페이지로 이동
            } else if (item.textContent.includes('비밀번호 변경')) {
                window.location.href = 'my_Change_Password.jsp';
            } else if (item.textContent.includes('회원탈퇴')) {
                window.location.href = 'my_Delete_Account.jsp';
            } else if (item.textContent.includes('가게정보수정')) {
                window.location.href = 'my_Store_Update.jsp';
            }
        });
    });
}

function checkDuplicate(type) {
    let inputId = "", messageId = "";
    switch (type) {
        case "nickname":
            inputId = "userNickname";
            messageId = "nicknameMessage";
            break;
        case "phone":
            inputId = "userPhone";
            messageId = "phoneMessage";
            break;
        case "email":
            inputId = "userEmail";
            messageId = "emailMessage";
            break;
        default:
            return;
    }

    const input = document.getElementById(inputId);
    const message = document.getElementById(messageId);
    const value = input.value.trim();
    const original = input.dataset.original;

    if (!value) {
        message.textContent = `${type === "nickname" ? "닉네임" : type === "phone" ? "휴대폰 번호" : "이메일"}을 입력해주세요.`;
        message.className = "info-msg error";
        return;
    }

    if (value === original) {
        message.textContent = `현재 사용 중인 ${type === "nickname" ? "닉네임" : type === "phone" ? "휴대폰 번호" : "이메일"}입니다.`;
        message.className = "info-msg";
        return;
    }

    fetch(contextPath + `/project/CheckDuplicateServlet?type=${type}&value=` + encodeURIComponent(value))
        .then(response => response.text())
        .then(data => {
            if (data.trim() === "duplicate") {
                message.textContent = `이미 등록된 ${type === "nickname" ? "닉네임" : type === "phone" ? "휴대폰 번호" : "이메일"}입니다.`;
                message.className = "info-msg error";
            } else {
                message.textContent = `사용 가능한 ${type === "nickname" ? "닉네임" : type === "phone" ? "번호" : "이메일"}입니다.`;
                message.className = "info-msg success";
            }
        })
        .catch(() => {
            message.textContent = "오류가 발생했습니다.";
            message.className = "info-msg error";
        });
}

function validateForm() {
	const nickname = document.getElementById("userNickname");
	const phone = document.getElementById("userPhone");
	const email = document.getElementById("userEmail");
	
	const nicknameMsg = document.getElementById("nicknameMessage");
	const phoneMsg = document.getElementById("phoneMessage");
	const emailMsg = document.getElementById("emailMessage");
	
	let valid = true;
	
	if (!nickname.value.trim()) {
	    nicknameMsg.textContent = "닉네임을 입력해주세요.";
	    nicknameMsg.className = "info-msg error";
	    valid = false;
	}
	
	if (!phone.value.trim()) {
	    phoneMsg.textContent = "휴대폰 번호를 입력해주세요.";
	    phoneMsg.className = "info-msg error";
	    valid = false;
	}
	
	if (!email.value.trim()) {
	    emailMsg.textContent = "이메일을 입력해주세요.";
	    emailMsg.className = "info-msg error";
	    valid = false;
	}
	
	return valid;
}

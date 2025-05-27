// 알림 팝업 관련 JavaScript 함수

// 팝업 열기 함수
function openNoticePopup() {
    // 팝업 요소 가져오기
    const popup = document.getElementById('noticePopup');
    const overlay = document.getElementById('noticeOverlay');
    
    // 오버레이 표시
    overlay.style.display = 'block';
    
	requestAnimationFrame(() => {
        popup.classList.add('show');
    });
}

// 팝업 닫기 함수
function closeNoticePopup() {
	const popup = document.getElementById('noticePopup');
    const overlay = document.getElementById('noticeOverlay');

    // 서버에 읽음 처리 요청 보내기
    fetch(`${contextPath}/project/mark_All_Read.jsp`, {
        method: 'GET'
    }).then(response => {
        if (response.ok) {
            // 빨간 점 제거
            const dot = document.getElementById('noticeDot');
            if (dot) {
                dot.remove();
            }
        }
    });

    // 팝업 닫기 (페이드아웃)
    popup.classList.remove('show');
    setTimeout(() => {
        overlay.style.display = 'none';
    }, 400);
}

// 알림 필터링 함수
function filterNotices(category) {
    // 모든 필터 버튼에서 활성 클래스 제거
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // 클릭한 버튼에 활성 클래스 추가
    event.target.classList.add('active');
    
    // 알림 필터링
    const notices = document.querySelectorAll('.notice-item');
    notices.forEach(notice => {
        if (category === '전체' || notice.getAttribute('data-category') === category) {
            notice.style.display = 'block';
        } else {
            notice.style.display = 'none';
        }
    });
	
	// '알림이 없습니다' 메시지 처리
	const visibleItems = Array.from(notices).filter(item => item.style.display !== 'none');
    const noNoticeMessage = document.getElementById('noNoticeMessage');
    noNoticeMessage.style.display = visibleItems.length === 0 ? 'block' : 'none';
}

// 알림 제거 함수
function removeNotice(button) {
    const noticeItem = button.closest('.notice-item');
	const noticeId = noticeItem.getAttribute('data-id'); // notice_id 값 가져오기

	// DB에서 삭제 요청 (GET 방식)
    fetch(`${contextPath}/project/notice_Popup.jsp?delete_id=${noticeId}`, {
        method: 'GET'
    }).then(response => {
        if (response.ok) {
            // 삭제 성공 시 애니메이션 처리
		    noticeItem.style.opacity = '0';
		    noticeItem.style.transform = 'translateX(30px)';
		    noticeItem.style.transition = 'opacity 0.3s, transform 0.3s';
		    
		    setTimeout(() => {
		        noticeItem.remove();
		        // 알림이 모두 제거되었는지 확인
		        if (document.querySelectorAll('.notice-item:not([style*="display: none"])').length === 0) {
		            // 현재 활성화된 카테고리 확인
		            const activeCategory = document.querySelector('.filter-btn.active').textContent;
		            if (activeCategory !== '전체') {
		                // 다른 카테고리에 알림이 있는지 확인
		                if (document.querySelectorAll('.notice-item').length > 0) {
		                    filterNotices('전체');
		                    document.querySelector('.filter-btn:first-child').classList.add('active');
		                }
		            }
		        }
		    }, 300);
		}
	});
}

// 문서 로드 완료 시 이벤트 리스너 설정
document.addEventListener('DOMContentLoaded', function() {
    // 오버레이 클릭 시 팝업 닫기
    const overlay = document.getElementById('noticeOverlay');
    if (overlay) {
        overlay.addEventListener('click', closeNoticePopup);
    }
});
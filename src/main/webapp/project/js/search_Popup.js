// 검색 팝업 열기
function openSearchPopup() {
	var searchPopup = document.getElementById('searchPopup');
    searchPopup.classList.add('active');
    document.body.style.overflow = 'hidden'; // 스크롤 잠금
	// 검색창에 포커스
	setTimeout(function() {
		document.querySelector('.search-input').focus();
	}, 100);
	// 저장된 최근 검색어 로드
	loadRecentSearches();
}

// 검색 팝업 닫기
function closeSearchPopup() {
	document.getElementById('searchPopup').classList.remove('active');
	document.body.style.overflow = ''; // 스크롤 복원
}

// 검색 실행 함수
function performSearch() {
	var searchInput = document.querySelector('.search-input');
	var searchTerm = searchInput.value.trim();

	if (searchTerm) {
		// 검색어 저장
		saveSearchTerm(searchTerm);
		// 검색 결과 페이지로 이동
		window.location.href = 'search_Result.jsp?keyword=' + encodeURIComponent(searchTerm);
	} else {
		alert("검색어를 입력해주세요.");
	}
}

// 사용자별 localStorage 키 설정
function getStorageKey() {
	const userId = sessionStorage.getItem("userId") || "guest";
	return `recentSearches_${userId}`;
}

// 최근 검색어 저장
function saveSearchTerm(term) {
	if (!term || term.trim() === '') return; // 빈 검색어 저장 방지
	
	let recentSearches = [];
	const storageKey = getStorageKey();
	try {
		const storedSearches = localStorage.getItem(storageKey);
		if (storedSearches) {
			recentSearches = JSON.parse(storedSearches);
		}
	} catch (e) {
		console.error('로컬 스토리지 파싱 오류:', e);
	}

	// 중복 검색어 제거
	recentSearches = recentSearches.filter(item => item !== term);
	// 새 검색어 추가 (맨 앞에)
	recentSearches.unshift(term);
	// 최대 10개만 유지
	if (recentSearches.length > 10) {
		recentSearches = recentSearches.slice(0, 10);
	}

	try {
		localStorage.setItem(storageKey, JSON.stringify(recentSearches));
	} catch (e) {
		console.error('로컬 스토리지 저장 오류:', e);
	}

	loadRecentSearches();
}

// 최근 검색어 로드 및 표시
function loadRecentSearches() {
	var searchTermsContainer = document.querySelector('.search-terms');
	if (!searchTermsContainer) return;

	let recentSearches = [];
	const storageKey = getStorageKey();
	try {
		const storedSearches = localStorage.getItem(storageKey);
		if (storedSearches) {
			recentSearches = JSON.parse(storedSearches);
		}
	} catch (e) {
		console.error('로컬 스토리지 파싱 오류:', e);
		recentSearches = [];
	}

	searchTermsContainer.innerHTML = '';

	for (let i = 0; i < recentSearches.length; i++) {
		const term = recentSearches[i];
		const termElement = document.createElement('div');
		termElement.className = 'search-term';

		const termSpan = document.createElement('span');
		termSpan.textContent = term;
		// 검색어 텍스트 클릭 시 검색 실행
		termSpan.addEventListener('click', function() {
			const searchInput = document.querySelector('.search-input');
			if (searchInput) {
				searchInput.value = this.textContent;
				performSearch(); // 검색 실행
			}
		});

		const deleteButton = document.createElement('button');
		deleteButton.className = 'term-delete';
		deleteButton.textContent = '✕';
		deleteButton.addEventListener('click', function(event) {
			event.stopPropagation(); // 버블링 방지
			removeSearchTerm(term);
		});

		termElement.appendChild(termSpan);
		termElement.appendChild(deleteButton);
		searchTermsContainer.appendChild(termElement);
	}
}

// 검색어 개별 삭제
function removeSearchTerm(term) {
	let recentSearches = [];
	const storageKey = getStorageKey();
	try {
		const storedSearches = localStorage.getItem(storageKey);
		if (storedSearches) {
			recentSearches = JSON.parse(storedSearches);
		}
	} catch (e) {
		console.error('로컬 스토리지 파싱 오류:', e);
	}

	recentSearches = recentSearches.filter(item => item !== term);

	try {
		localStorage.setItem(storageKey, JSON.stringify(recentSearches));
	} catch (e) {
		console.error('로컬 스토리지 저장 오류:', e);
	}

	loadRecentSearches();
}

// 검색어 전체 삭제
function clearAllSearchTerms() {
	const storageKey = getStorageKey();
	try {
		localStorage.removeItem(storageKey);
	} catch (e) {
		console.error('로컬 스토리지 삭제 오류:', e);
	}

	const searchTermsContainer = document.querySelector('.search-terms');
	if (searchTermsContainer) {
		searchTermsContainer.innerHTML = '';
	}
}

// 태그 클릭 시 검색어 설정 및 검색
function setSearchTerm(tagText) {
    document.querySelector('.search-input').value = tagText; // 입력창에 태그 텍스트 설정
    saveSearchTerm(tagText); // 태그 검색어도 최근 검색어에 저장
    performSearch(); // 검색 실행
}

// 문서 로드 완료 시 이벤트 등록
document.addEventListener('DOMContentLoaded', function() {
	// 검색 입력창 엔터키 이벤트
	const searchInput = document.querySelector('.search-input');
	if (searchInput) {
		searchInput.addEventListener('keypress', function(e) {
			if (e.key === 'Enter') {
				e.preventDefault(); // 폼 기본 제출 방지
				performSearch();
			}
		});
	}

	// 검색 폼 제출 이벤트
	const searchForm = document.querySelector('.search-form');
	if (searchForm) {
		searchForm.addEventListener('submit', function(event) {
			const searchTerm = document.querySelector('.search-input').value.trim();
			if (!searchTerm) {
				alert("검색어를 입력해주세요.");
				event.preventDefault(); // 검색어가 없으면 폼 제출 취소
			} else {
				saveSearchTerm(searchTerm); // 검색어 저장
			}
		});
	}

	// 최근 검색어 로드
	loadRecentSearches();
	
	// 로그인 필요한 링크 처리
	const protectedLinks = document.querySelectorAll('[data-login-required="true"]');
	protectedLinks.forEach(link => {
		link.addEventListener("click", function (e) {
			if (!isLoggedIn) {
				e.preventDefault();
				document.getElementById("loginAlertModal").style.display = "flex";
			}
		});
	});
});
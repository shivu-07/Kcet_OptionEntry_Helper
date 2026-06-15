/* ═══════════════════════════════════════════════════════════════
   KCET Option Entry Helper — app.js
   All frontend logic in 6 sections
═══════════════════════════════════════════════════════════════ */

/* ══════════════════════════════════════════════════════════════
   SECTION 1 — STATE
══════════════════════════════════════════════════════════════ */
const state = {
  filters: {
    search:           "",
    district_id:      "",
    institution_type: "",
    autonomous:       "",
    course:           "",
    category:         "",
    sort:             "name",
    rank_min:         "",
    rank_max:         "",
  },
  page:       1,
  totalPages: 1,
  colleges:   [],
  options:    [],
  addedSet:   new Set(),   // "collegeId::courseName" keys
  debounceTimer: null,
  districtCounts: {},
  totalColleges: 0,
};

/* ══════════════════════════════════════════════════════════════
   SECTION 2 — INIT
══════════════════════════════════════════════════════════════ */
async function init() {
  await loadFilters();
  await Promise.all([loadColleges(1), loadOptions(), loadStats(), loadServerInfo()]);
}

async function loadServerInfo() {
  try {
    const data = await apiFetch("/api/server-info");
    const el = document.getElementById("stat-lan");
    if (el && data.lan_url) {
      el.textContent = `📶 Share on Wi-Fi: ${data.lan_url}`;
      el.title = "Open this address on any phone/laptop on the same Wi-Fi network";
    }
  } catch (_) {}
}

async function loadStats() {
  try {
    const data = await apiFetch("/api/stats");
    document.getElementById("stat-colleges").textContent =
      `${data.colleges} colleges`;
    document.getElementById("stat-options").textContent =
      `${data.my_options} option${data.my_options !== 1 ? "s" : ""} saved`;
  } catch (_) {}
}

/* ══════════════════════════════════════════════════════════════
   SECTION 3 — FILTER PANEL
══════════════════════════════════════════════════════════════ */
async function loadFilters() {
  const data = await apiFetch("/api/filters");

  // Populate district dropdown
  const distSel = document.getElementById("f-district");
  state.districtCounts = {};
  state.totalColleges = data.total_colleges || 0;
  data.districts.forEach(d => {
    state.districtCounts[d.id] = d.college_count;
    const opt = document.createElement("option");
    opt.value = d.id;
    opt.textContent = d.name;
    distSel.appendChild(opt);
  });

  // Populate institution type dropdown
  const typeSel = document.getElementById("f-type");
  data.institution_types.forEach(t => {
    const opt = document.createElement("option");
    opt.value = t;
    // Shorten long labels
    opt.textContent = shortType(t);
    typeSel.appendChild(opt);
  });

  // Populate course dropdown
  const courseSel = document.getElementById("f-course");
  data.courses.forEach(c => {
    const opt = document.createElement("option");
    opt.value = c;
    opt.textContent = c;
    courseSel.appendChild(opt);
  });

  // Populate category dropdown
  const catHtml = Object.entries(data.seat_categories).map(([code, desc]) =>
    `<option value="${code}">${code} — ${desc}</option>`
  ).join("");
  document.getElementById("f-category").insertAdjacentHTML("beforeend", catHtml);
}

function shortType(t) {
  const map = {
    "Government Engineering Colleges / VTU Constituent Colleges": "Government / VTU",
    "Aided Engineering Colleges":                  "Aided (Govt-funded)",
    "Private Unaided Engineering Colleges":        "Private Unaided",
    "Private Unaided Minority Colleges":           "Private Minority",
    "Government Courses in Public Universities":   "Public Universities",
    "Private Universities":                        "Private Universities",
    "Deemed Universities":                         "Deemed Universities",
    "Government Colleges with Higher Fees":        "Govt (Higher Fees)",
  };
  return map[t] || t;
}

function applyFilters() {
  state.filters.district_id      = document.getElementById("f-district").value;
  state.filters.institution_type = document.getElementById("f-type").value;
  state.filters.autonomous       = document.getElementById("f-autonomous").value;
  state.filters.course           = document.getElementById("f-course").value;
  state.filters.category         = document.getElementById("f-category").value;
  state.filters.rank_min         = document.getElementById("f-rank-min").value;
  state.filters.rank_max         = document.getElementById("f-rank-max").value;

  const catWrap      = document.getElementById("f-cat-wrap");
  const rankWrap     = document.getElementById("f-rank-wrap");
  const rankAscOpt   = document.getElementById("f-sort-rank-asc");
  const rankDescOpt  = document.getElementById("f-sort-rank-desc");
  const sortSelect   = document.getElementById("f-sort");
  const rankLabel    = document.getElementById("f-rank-label");

  if (state.filters.course) {
    catWrap.style.display = "block";
    
    if (state.filters.category) {
      rankWrap.style.display = "block";
      rankAscOpt.style.display = "block";
      rankDescOpt.style.display = "block";
      rankLabel.textContent = `${state.filters.category} Rank range`;

      // Auto-switch to rank_asc if we just selected a category and sort was name
      if (!sortSelect.dataset.rankSelected) {
         sortSelect.value = "rank_asc";
         sortSelect.dataset.rankSelected = "true";
      }
    } else {
      rankWrap.style.display = "none";
      rankAscOpt.style.display = "none";
      rankDescOpt.style.display = "none";
      sortSelect.dataset.rankSelected = "";
      
      // Reset sort if it was on rank
      if (sortSelect.value.startsWith("rank")) {
        sortSelect.value = "name";
      }
    }
  } else {
    catWrap.style.display = "none";
    rankWrap.style.display = "none";
    rankAscOpt.style.display = "none";
    rankDescOpt.style.display = "none";
    sortSelect.dataset.rankSelected = "";
    document.getElementById("f-category").value = "";
    state.filters.category = "";
    
    // Reset sort if it was on rank
    if (sortSelect.value.startsWith("rank")) {
      sortSelect.value = "name";
    }
  }

  state.filters.sort = sortSelect.value;
  loadColleges(1);
}

function debounceSearch() {
  clearTimeout(state.debounceTimer);
  state.debounceTimer = setTimeout(() => {
    state.filters.search = document.getElementById("f-search").value;
    loadColleges(1);
  }, 300);
}

function resetFilters() {
  document.getElementById("f-search").value      = "";
  document.getElementById("f-district").value    = "";
  document.getElementById("f-type").value        = "";
  document.getElementById("f-autonomous").value  = "";
  document.getElementById("f-course").value      = "";
  document.getElementById("f-category").value    = "";
  document.getElementById("f-sort").value      = "name";
  document.getElementById("f-rank-min").value  = "";
  document.getElementById("f-rank-max").value  = "";
  
  document.getElementById("f-cat-wrap").style.display = "none";
  document.getElementById("f-rank-wrap").style.display = "none";
  document.getElementById("f-sort-rank-asc").style.display = "none";
  document.getElementById("f-sort-rank-desc").style.display = "none";
  document.getElementById("f-sort").dataset.rankSelected = "";

  Object.assign(state.filters, {
    search:"", district_id:"", institution_type:"",
    autonomous:"", course:"", category:"",
    sort:"name", rank_min:"", rank_max:""
  });
  loadColleges(1);
}

/* ══════════════════════════════════════════════════════════════
   SECTION 4 — COLLEGE CARDS
══════════════════════════════════════════════════════════════ */
async function loadColleges(page = 1) {
  state.page = page;

  const params = new URLSearchParams();
  if (state.filters.search)           params.set("search",           state.filters.search);
  if (state.filters.district_id)      params.set("district_id",      state.filters.district_id);
  if (state.filters.institution_type) params.set("institution_type", state.filters.institution_type);
  if (state.filters.autonomous)       params.set("autonomous",       state.filters.autonomous);
  if (state.filters.course)           params.set("course",           state.filters.course);
  if (state.filters.category)         params.set("category",         state.filters.category);
  if (state.filters.rank_min)         params.set("rank_min",         state.filters.rank_min);
  if (state.filters.rank_max)         params.set("rank_max",         state.filters.rank_max);
  params.set("sort",  state.filters.sort);
  params.set("page",  page);
  params.set("limit", 300);

  const list = document.getElementById("college-list");

  if (page === 1) {
    list.innerHTML = '<div class="loading">Loading…</div>';
  }

  const data = await apiFetch(`/api/colleges?${params}`);

  state.totalPages = data.pages;

  if (page === 1) {
    state.colleges = data.results;
    list.innerHTML = "";
  } else {
    state.colleges = [...state.colleges, ...data.results];
  }

  if (data.results.length === 0 && page === 1) {
    list.innerHTML = '<div class="empty-state"><p>No colleges match your filters.</p></div>';
    let totalDenominator = state.totalColleges;
    if (state.filters.district_id) {
      totalDenominator = state.districtCounts[state.filters.district_id] || totalDenominator;
    }
    document.getElementById("filter-results").textContent = `Showing 0 of ${totalDenominator}`;
    document.getElementById("load-more-wrap").style.display = "none";
    return;
  }

  // Render cards for this page only
  data.results.forEach(college => {
    list.appendChild(buildCollegeCard(college));
  });


  
  const displayedCount = state.colleges.length;
  let totalDenominator = state.totalColleges;
  if (state.filters.district_id) {
    totalDenominator = state.districtCounts[state.filters.district_id] || totalDenominator;
  }
  document.getElementById("filter-results").textContent =
    `Showing ${displayedCount} of ${totalDenominator}`;

  const loadMoreWrap = document.getElementById("load-more-wrap");
  loadMoreWrap.style.display = (page < data.pages) ? "block" : "none";
}

function buildCollegeCard(college) {
  const card = document.createElement("div");
  card.className = `card${college.college_code ? "" : " no-cutoff"}`;
  card.dataset.id = college.id;
  card.dataset.autonomous = college.is_autonomous ? "1" : "0";

  const cutoffBtn = college.college_code
    ? `<button class="btn btn-cutoff" onclick="event.stopPropagation(); openCutoffModal(${college.id}, '${escJs(college.name)}', '${escJs(college.college_code)}')">📊 Cutoff</button>` : "";
  const codeBadge = college.college_code
    ? `<span class="badge badge-code">${college.college_code}</span>` : "";
  const typeBadge =
    `<span class="badge badge-type">${shortType(college.institution_type)}</span>`;
  const distBadge = college.district
    ? `<span class="badge badge-dist">${college.district}</span>` : "";
  const autoBadge = college.is_autonomous
    ? '<span class="badge badge-auto">Autonomous</span>' : "";

  const branchCount = college.courses.length;

  card.innerHTML = `
    <div class="card-body">
      <div class="card-top-row">
        ${codeBadge}
        ${cutoffBtn}
      </div>
      <div class="card-tags">
        ${typeBadge}${distBadge}${autoBadge}
      </div>
      <div class="college-name">${escHtml(college.name)}</div>
      <div class="card-branch-count">
        📚 ${branchCount} branch${branchCount !== 1 ? "es" : ""}
      </div>
    </div>
  `;

  card.addEventListener("click", () => openCoursePopup(college));
  return card;
}

function buildCourseRow(collegeId, collegeName, course) {
  const key   = `${collegeId}::${course}`;
  const added = state.addedSet.has(key);

  const row = document.createElement("div");
  row.className = "course-row";
  row.id = `cr-${collegeId}-${btoa(course).replace(/=/g,'').substring(0,10)}`;

  row.innerHTML = `
    <span class="course-name-text"
          onmouseenter="showTooltip(event, ${collegeId}, '${escJs(course)}')"
          onmouseleave="hideTooltip()">
      ${escHtml(course)}
    </span>
    <button class="btn-add ${added ? 'added' : ''}"
            id="addbtn-${collegeId}-${hashStr(course)}"
            ${added ? 'disabled' : ''}
            onclick="addOption(${collegeId}, '${escJs(course)}', '${escJs(collegeName)}')">
      ${added ? "✓ Added" : "+ Add"}
    </button>
  `;
  return row;
}

function buildRankBadge(rank) {
  if (!rank) return '<span class="badge badge-rank rank-none">No data</span>';
  const cls = rank < 5000  ? "rank-great"
            : rank < 50000 ? "rank-good"
            : "rank-high";
  return `<span class="badge badge-rank ${cls}">#${Math.round(rank).toLocaleString()}</span>`;
}

function loadMore() {
  loadColleges(state.page + 1);
}

/* ══════════════════════════════════════════════════════════════
   SECTION 5 — TOOLTIP (cutoff preview on hover)
══════════════════════════════════════════════════════════════ */
let tooltipTimer = null;
let tooltipData  = {};

async function showTooltip(event, collegeId, course) {
  clearTimeout(tooltipTimer);
  tooltipTimer = setTimeout(async () => {
    const tip = document.getElementById("tooltip");

    // Fetch if not cached
    if (!tooltipData[collegeId]) {
      try {
        tooltipData[collegeId] = await apiFetch(`/api/college/${collegeId}/cutoffs`);
      } catch(_) { return; }
    }

    const data    = tooltipData[collegeId];
    const cutoff  = data.cutoffs.find(c => c.course.toUpperCase() === course.toUpperCase());
    if (!cutoff) return;

    const cats = ["GM","1G","2AG","2BG","3AG","3BG","SCG","STG","NRI"];
    const rows = cats
      .filter(cat => cutoff[cat] != null)
      .map(cat => `<div class="tooltip-row">
        <span class="tooltip-cat">${cat}</span>
        <span class="tooltip-rank">#${Math.round(cutoff[cat]).toLocaleString()}</span>
      </div>`)
      .join("");

    if (!rows) return;

    tip.innerHTML = `<div style="font-weight:600;margin-bottom:.35rem;font-size:.75rem">${course}</div>${rows}`;
    tip.style.display = "block";

    // Position
    const rect = event.target.getBoundingClientRect();
    tip.style.left = `${rect.left}px`;
    tip.style.top  = `${rect.top - tip.offsetHeight - 8}px`;

  }, 350);
}

function hideTooltip() {
  clearTimeout(tooltipTimer);
  const tip = document.getElementById("tooltip");
  tip.style.display = "none";
}

/* ══════════════════════════════════════════════════════════════
   SECTION 6 — OPTIONS LIST + DRAG-TO-REORDER
══════════════════════════════════════════════════════════════ */
async function loadOptions() {
  const data = await apiFetch("/api/options");
  state.options = data;

  // Rebuild addedSet
  state.addedSet.clear();
  data.forEach(o => state.addedSet.add(`${o.college_id}::${o.course_name}`));

  renderOptions();
  syncAddButtons();
  updateExportBtn();
  loadStats();
}

function renderOptions() {
  const list = document.getElementById("options-list");
  const count = document.getElementById("options-count");
  const mobileCount = document.getElementById("mobile-options-count");

  count.textContent = state.options.length;
  if (mobileCount) mobileCount.textContent = state.options.length;

  if (state.options.length === 0) {
    list.innerHTML = `
      <div class="empty-state">
        <p>No options added yet.</p>
        <p class="empty-sub">Click <strong>+ Add</strong> on any course to add it here.</p>
      </div>`;
    return;
  }

  list.innerHTML = "";
  state.options.forEach(opt => {
    list.appendChild(buildOptionItem(opt));
  });
}

function buildOptionItem(opt) {
  const item = document.createElement("div");
  item.className = "option-item";
  item.draggable = true;
  item.dataset.id = opt.id;

  const rankText = opt.gm_rank
    ? `<div class="option-rank">GM Rank: #${Math.round(opt.gm_rank).toLocaleString()}</div>`
    : "";

  item.innerHTML = `
    <div class="option-num">${opt.priority}</div>
    <div class="option-body">
      <div class="option-college" title="${escHtml(opt.college_name)}">
        ${opt.college_code ? `<span style="font-family:monospace;font-size:.68rem;background:var(--gray-800);color:#fff;padding:.1rem .35rem;border-radius:3px;margin-right:.3rem">${opt.college_code}</span>` : ""}
        ${escHtml(opt.college_name)}
      </div>
      <div class="option-course">${escHtml(opt.course_name)}</div>
      ${rankText}
      <input class="option-notes"
             placeholder="Add notes…"
             value="${escHtml(opt.notes || '')}"
             onblur="saveNotes(${opt.id}, this.value)"/>
    </div>
    <div class="option-actions">
      <span class="drag-handle">⠿</span>
      <button class="btn-icon" onclick="removeOption(${opt.id})" title="Remove">✕</button>
    </div>
  `;

  // Drag events
  item.addEventListener("dragstart",  onDragStart);
  item.addEventListener("dragover",   onDragOver);
  item.addEventListener("dragleave",  onDragLeave);
  item.addEventListener("drop",       onDrop);
  item.addEventListener("dragend",    onDragEnd);

  return item;
}

async function addOption(collegeId, course, collegeName) {
  const key = `${collegeId}::${course}`;
  if (state.addedSet.has(key)) return;

  try {
    await apiFetch("/api/options", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ college_id: collegeId, course_name: course })
    });
    state.addedSet.add(key);
    await loadOptions();
    // Flash the options panel
    document.getElementById("options-list").scrollTop = 999999;
  } catch (e) {
    if (e.status === 409) alert("Already in your list!");
    else alert("Could not add option. Please try again.");
  }
}

async function removeOption(optId) {
  await apiFetch(`/api/options/${optId}`, { method: "DELETE" });
  await loadOptions();
}

async function saveNotes(optId, notes) {
  await apiFetch(`/api/options/${optId}/notes`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ notes })
  });
}

function syncAddButtons() {
  // Update all visible Add buttons to reflect current addedSet
  document.querySelectorAll("[id^='addbtn-']").forEach(btn => {
    const parts     = btn.id.split("-");
    const collegeId = parts[1];
    // Find the course by looking at sibling text
    const courseEl  = btn.previousElementSibling;
    if (!courseEl) return;
    const course    = courseEl.textContent.trim();
    const key       = `${collegeId}::${course}`;
    const added     = state.addedSet.has(key);
    btn.className   = `btn-add ${added ? "added" : ""}`;
    btn.disabled    = added;
    btn.textContent = added ? "✓ Added" : "+ Add";
  });
}

function updateExportBtn() {
  document.getElementById("btn-export-pdf").disabled = state.options.length === 0;
}

/* ── Drag-and-drop ─────────────────────────────────────────── */
let dragSrcId = null;

function onDragStart(e) {
  dragSrcId = this.dataset.id;
  this.classList.add("dragging");
  e.dataTransfer.effectAllowed = "move";
}
function onDragOver(e) {
  e.preventDefault();
  e.dataTransfer.dropEffect = "move";
  this.classList.add("drag-over");
}
function onDragLeave() {
  this.classList.remove("drag-over");
}
function onDrop(e) {
  e.stopPropagation();
  this.classList.remove("drag-over");
  if (dragSrcId === this.dataset.id) return;

  // Reorder DOM
  const list  = document.getElementById("options-list");
  const items = [...list.querySelectorAll(".option-item")];
  const srcEl = items.find(i => i.dataset.id === dragSrcId);
  const dstEl = this;

  if (!srcEl) return;

  const srcIdx = items.indexOf(srcEl);
  const dstIdx = items.indexOf(dstEl);

  if (srcIdx < dstIdx) {
    list.insertBefore(srcEl, dstEl.nextSibling);
  } else {
    list.insertBefore(srcEl, dstEl);
  }

  // Save new order to server
  const newOrder = [...list.querySelectorAll(".option-item")].map(i => parseInt(i.dataset.id));
  apiFetch("/api/options/reorder", {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ order: newOrder })
  }).then(() => loadOptions());
}
function onDragEnd() {
  this.classList.remove("dragging");
  document.querySelectorAll(".option-item").forEach(i => i.classList.remove("drag-over"));
}

/* ══════════════════════════════════════════════════════════════
   SECTION 7 — COURSE POPUP (on card click)
══════════════════════════════════════════════════════════════ */
function openCoursePopup(college) {
  const modalTitle = document.getElementById("modal-title");
  const modalSub   = document.getElementById("modal-sub");
  const modalBody  = document.getElementById("modal-body");

  modalTitle.textContent = college.name;

  const subParts = [];
  if (college.college_code) subParts.push(`Code: ${college.college_code}`);
  if (college.district)     subParts.push(college.district);
  subParts.push(shortType(college.institution_type));
  if (college.is_autonomous) subParts.push("Autonomous");
  modalSub.textContent = subParts.join(" · ");

  let html = `<div class="popup-courses-header">
    ${college.courses.length} course${college.courses.length !== 1 ? "s" : ""} offered — click <strong>+ Add</strong> to add to your option list
  </div>`;

  html += '<div class="popup-courses">';
  college.courses.forEach(courseObj => {
    const course = courseObj.name;
    const cutoff = courseObj.gm_cutoff;
    const key   = `${college.id}::${course}`;
    const added = state.addedSet.has(key);

    html += `
      <div class="course-row">
        <span class="course-name-text"
              onmouseenter="showTooltip(event, ${college.id}, '${escJs(course)}')"
              onmouseleave="hideTooltip()">
          ${escHtml(course)}
        </span>
        <div style="display:flex; align-items:center; gap:.5rem; flex-shrink:0;">
          <button class="btn btn-course-cutoff" onclick="showSingleCourseCutoff(${college.id}, '${escJs(course)}', '${escJs(college.name)}', '${escJs(college.college_code)}')">
            📊 Cutoffs
          </button>
          <button class="btn-add ${added ? 'added' : ''}"
                  id="addbtn-${college.id}-${hashStr(course)}"
                  ${added ? 'disabled' : ''}
                  onclick="addOption(${college.id}, '${escJs(course)}', '${escJs(college.name)}')">
            ${added ? '✓ Added' : '+ Add'}
          </button>
        </div>
      </div>`;
  });
  html += '</div>';

  modalBody.innerHTML = html;
  document.getElementById("modal-overlay").classList.add("open");
  document.addEventListener("keydown", onModalKey);
}

/* ══════════════════════════════════════════════════════════════
   SECTION 8 — CUTOFF MODAL
══════════════════════════════════════════════════════════════ */
async function showSingleCourseCutoff(collegeId, course, collegeName, collegeCode) {
  const modalSub = document.getElementById("modal-sub");
  modalSub.innerHTML = `
    <button class="btn-link" style="padding:0; margin-right:.5rem; color:var(--blue);" onclick="openCoursePopup(state.colleges.find(c => c.id === ${collegeId}))">← Back to courses</button>
    ${collegeCode ? `KCET Code: ${collegeCode}` : "No KCET code"}
  `;
  document.getElementById("modal-title").textContent = course;
  document.getElementById("modal-body").innerHTML = '<div class="loading">Loading cutoff data…</div>';

  try {
    const data = await apiFetch(`/api/college/${collegeId}/cutoffs`);
    
    // Filter for just this course
    const courseData = data.cutoffs ? data.cutoffs.filter(r => r.course === course) : [];

    if (courseData.length === 0) {
      document.getElementById("modal-body").innerHTML =
        '<div class="empty-state"><p>No cutoff data available for this course.</p></div>';
      return;
    }

    const cats = ["GM","GMK","GMR","GMP","OPN","1G","1K","1R","2AG","2AK","2AR",
                  "2BG","2BK","2BR","3AG","3AK","3AR","3BG","3BK","3BR",
                  "SCG","SCK","SCR","STG","STK","STR","NRI","OTH"];

    let html = `<table class="cutoff-table">
      <thead><tr>
        <th>Category</th>
        <th>Cutoff Rank</th>
      </tr></thead><tbody>`;

    const row = courseData[0];
    cats.forEach(cat => {
      if (row[cat] == null) {
        html += `<tr>
          <td style="font-weight:600;">${cat}</td>
          <td class="null-cell" style="text-align:left;">--</td>
        </tr>`;
      } else {
        const r = Math.round(row[cat]);
        const cls = r < 5000 ? "rank-great" : r < 50000 ? "rank-good" : "rank-high";
        html += `<tr>
          <td style="font-weight:600;">${cat}</td>
          <td class="${cls}" style="text-align:left;">${r.toLocaleString()}</td>
        </tr>`;
      }
    });
    
    html += `</tbody></table>`;
    document.getElementById("modal-body").innerHTML = html;
  } catch (err) {
    document.getElementById("modal-body").innerHTML =
      `<div class="empty-state" style="color:var(--red)">Failed to load data.</div>`;
  }
}

async function openCutoffModal(collegeId, collegeName, collegeCode) {
  document.getElementById("modal-title").textContent = collegeName;
  document.getElementById("modal-sub").textContent =
    collegeCode ? `KCET Code: ${collegeCode} · Click a course row to add it to your list` : "No KCET code — not in counselling data";
  document.getElementById("modal-body").innerHTML = '<div class="loading">Loading cutoff data…</div>';
  document.getElementById("modal-overlay").classList.add("open");
  document.addEventListener("keydown", onModalKey);

  try {
    const data = await apiFetch(`/api/college/${collegeId}/cutoffs`);

    if (!data.cutoffs || data.cutoffs.length === 0) {
      document.getElementById("modal-body").innerHTML =
        '<div class="empty-state"><p>No cutoff data available for this college.</p></div>';
      return;
    }

    const cats = ["GM","GMK","GMR","GMP","OPN","1G","1K","1R","2AG","2AK","2AR",
                  "2BG","2BK","2BR","3AG","3AK","3AR","3BG","3BK","3BR",
                  "SCG","SCK","SCR","STG","STK","STR","NRI","OTH"];

    // Only show categories that actually have data
    const activeCats = cats.filter(cat =>
      data.cutoffs.some(row => row[cat] != null)
    );

    let html = `<table class="cutoff-table">
      <thead><tr>
        <th>Course</th>
        ${activeCats.map(c => `<th>${c}</th>`).join("")}
        <th>Action</th>
      </tr></thead><tbody>`;

    data.cutoffs.forEach(row => {
      html += `<tr>
        <td>${escHtml(row.course)}</td>
        ${activeCats.map(cat => {
          if (row[cat] == null) return '<td class="null-cell">--</td>';
          const r   = Math.round(row[cat]);
          const cls = r < 5000 ? "rank-great" : r < 50000 ? "rank-good" : "rank-high";
          return `<td class="${cls}">${r.toLocaleString()}</td>`;
        }).join("")}
        <td>
          <button class="btn-add" onclick="addOption(${collegeId}, '${escJs(row.course)}', '${escJs(collegeName)}'); closeModalBtn()">
            + Add
          </button>
        </td>
      </tr>`;
    });

    html += "</tbody></table>";
    document.getElementById("modal-body").innerHTML = html;
  } catch (_) {
    document.getElementById("modal-body").innerHTML =
      '<div class="empty-state"><p>Failed to load cutoff data.</p></div>';
  }
}

function closeModal(e) {
  if (e.target === document.getElementById("modal-overlay")) closeModalBtn();
}
function closeModalBtn() {
  document.getElementById("modal-overlay").classList.remove("open");
  document.removeEventListener("keydown", onModalKey);
}
function onModalKey(e) {
  if (e.key === "Escape") closeModalBtn();
}

/* ══════════════════════════════════════════════════════════════
   SECTION 8 — EXPORT
══════════════════════════════════════════════════════════════ */
function exportPDF() {
  if (state.options.length === 0) return;
  window.location = "/api/export-pdf";
}

/* ══════════════════════════════════════════════════════════════
   UTILITIES
══════════════════════════════════════════════════════════════ */
async function apiFetch(url, options = {}) {
  const res = await fetch(url, options);
  if (!res.ok) {
    const err = new Error(`HTTP ${res.status}`);
    err.status = res.status;
    throw err;
  }
  return res.json();
}

function escHtml(str) {
  return String(str || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function escJs(str) {
  return String(str || "")
    .replace(/\\/g, "\\\\")
    .replace(/'/g, "\\'")
    .replace(/"/g, '\\"');
}

function hashStr(str) {
  let h = 0;
  for (let i = 0; i < str.length; i++) {
    h = (Math.imul(31, h) + str.charCodeAt(i)) | 0;
  }
  return Math.abs(h).toString(36);
}

/* ══════════════════════════════════════════════════════════════
   MOBILE OFF-CANVAS MENUS
══════════════════════════════════════════════════════════════ */
function toggleMobileFilters() {
  document.querySelector(".panel-filter").classList.toggle("open");
  document.querySelector(".panel-options").classList.remove("open");
  updateMobileBackdrop();
}

function toggleMobileOptions() {
  document.querySelector(".panel-options").classList.toggle("open");
  document.querySelector(".panel-filter").classList.remove("open");
  updateMobileBackdrop();
}

function closeMobilePanels() {
  document.querySelector(".panel-filter").classList.remove("open");
  document.querySelector(".panel-options").classList.remove("open");
  updateMobileBackdrop();
}

function updateMobileBackdrop() {
  const isAnyOpen = document.querySelector(".panel-filter").classList.contains("open") ||
                    document.querySelector(".panel-options").classList.contains("open");
  if (isAnyOpen) {
    document.getElementById("mobile-backdrop").classList.add("open");
  } else {
    document.getElementById("mobile-backdrop").classList.remove("open");
  }
}

/* ══════════════════════════════════════════════════════════════
   START
══════════════════════════════════════════════════════════════ */
document.addEventListener("DOMContentLoaded", init);

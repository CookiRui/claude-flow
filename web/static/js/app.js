// Knowledge Base Web UI - app.js
// Single-file frontend: tree nav, doc render, backlinks, tag cloud, search, edit

(function () {
  'use strict';

  // --- State ---
  let currentDocPath = null;
  let currentRawMarkdown = '';
  let isEditing = false;

  // --- DOM refs ---
  const treeContainer = document.getElementById('tree-container');
  const docContent = document.getElementById('doc-content');
  const docHeader = document.getElementById('doc-header');
  const docTitle = document.getElementById('doc-title');
  const docMeta = document.getElementById('doc-meta');
  const backlinksList = document.getElementById('backlinks-list');
  const tagCloud = document.getElementById('tag-cloud');
  const searchInput = document.getElementById('search-input');
  const searchResults = document.getElementById('search-results');
  const btnEdit = document.getElementById('btn-edit');
  const btnSave = document.getElementById('btn-save');
  const btnCancel = document.getElementById('btn-cancel');
  const editorArea = document.getElementById('editor-area');
  const editorTextarea = document.getElementById('editor-textarea');

  // --- API helpers ---

  async function apiFetch(url, options) {
    try {
      const res = await fetch(url, options);
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      return await res.json();
    } catch (err) {
      console.error('API error:', err);
      showError(err.message);
      return null;
    }
  }

  function showError(msg) {
    docContent.innerHTML = `<div class="error-msg">Error: ${escapeHtml(msg)}</div>`;
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  // --- Marked.js configuration ---

  function configureMarked() {
    const renderer = new marked.Renderer();

    // Syntax highlighting for code blocks
    renderer.code = function (code, lang) {
      if (lang && hljs.getLanguage(lang)) {
        const highlighted = hljs.highlight(code, { language: lang }).value;
        return `<pre><code class="hljs language-${escapeHtml(lang)}">${highlighted}</code></pre>`;
      }
      const escaped = hljs.highlightAuto(code).value;
      return `<pre><code class="hljs">${escaped}</code></pre>`;
    };

    marked.setOptions({ renderer: renderer, breaks: true });
  }

  // --- Wikilink processing ---

  function processWikilinks(html) {
    // [[target|alias]] -> clickable link with alias text
    // [[target]] -> clickable link with target text
    return html.replace(/\[\[([^\]|]+?)(?:\|([^\]]+?))?\]\]/g, function (match, target, alias) {
      const display = alias || target;
      const safePath = escapeHtml(target.trim());
      const safeDisplay = escapeHtml(display.trim());
      return `<a href="#" class="wikilink" data-target="${safePath}">${safeDisplay}</a>`;
    });
  }

  // --- Tree rendering ---

  async function loadTree() {
    const data = await apiFetch('/api/tree');
    if (!data) return;
    treeContainer.innerHTML = '';
    renderTreeNodes(data, treeContainer);
  }

  function renderTreeNodes(nodes, parentEl) {
    const ul = document.createElement('ul');
    ul.className = 'tree-list';
    for (const node of nodes) {
      const li = document.createElement('li');
      li.className = 'tree-node';

      if (node.children && node.children.length > 0) {
        // Directory node
        const toggle = document.createElement('span');
        toggle.className = 'tree-toggle';
        toggle.textContent = '▶';
        toggle.addEventListener('click', function () {
          const isExpanded = li.classList.toggle('expanded');
          toggle.textContent = isExpanded ? '▼' : '▶';
        });
        li.appendChild(toggle);

        const label = document.createElement('span');
        label.className = 'tree-dir';
        label.textContent = node.name;
        li.appendChild(label);

        renderTreeNodes(node.children, li);
      } else {
        // File node
        const link = document.createElement('a');
        link.className = 'tree-file';
        link.href = '#';
        link.textContent = node.name;
        link.dataset.path = node.path;
        link.addEventListener('click', function (e) {
          e.preventDefault();
          loadDocument(node.path);
        });
        li.appendChild(link);
      }
      ul.appendChild(li);
    }
    parentEl.appendChild(ul);
  }

  // --- Document loading and rendering ---

  async function loadDocument(path) {
    exitEditMode();
    currentDocPath = path;

    const data = await apiFetch('/api/doc?path=' + encodeURIComponent(path));
    if (!data) return;

    currentRawMarkdown = data.content || '';

    // Title and meta
    docTitle.textContent = data.metadata?.title || path.split('/').pop().replace(/\.md$/, '');
    const metaParts = [];
    if (data.metadata?.date) metaParts.push('Date: ' + data.metadata.date);
    if (data.metadata?.tags && data.metadata.tags.length) {
      metaParts.push('Tags: ' + data.metadata.tags.join(', '));
    }
    if (data.metadata?.status) metaParts.push('Status: ' + data.metadata.status);
    docMeta.textContent = metaParts.join(' | ');

    docHeader.classList.remove('hidden');
    btnEdit.classList.remove('hidden');

    // Render markdown
    let html = marked.parse(currentRawMarkdown);
    html = processWikilinks(html);
    docContent.innerHTML = html;

    // Attach wikilink click handlers
    docContent.querySelectorAll('.wikilink').forEach(function (el) {
      el.addEventListener('click', function (e) {
        e.preventDefault();
        loadDocument(el.dataset.target);
      });
    });

    // Render backlinks
    renderBacklinks(data.backlinks || []);

    // Highlight active tree item
    treeContainer.querySelectorAll('.tree-file').forEach(function (el) {
      el.classList.toggle('active', el.dataset.path === path);
    });
  }

  // --- Backlinks panel ---

  function renderBacklinks(backlinks) {
    backlinksList.innerHTML = '';
    if (backlinks.length === 0) {
      backlinksList.innerHTML = '<li class="no-backlinks">No backlinks found</li>';
      return;
    }
    for (const link of backlinks) {
      const li = document.createElement('li');
      const a = document.createElement('a');
      a.href = '#';
      a.textContent = link.title || link.path;
      a.dataset.path = link.path;
      a.addEventListener('click', function (e) {
        e.preventDefault();
        loadDocument(link.path);
      });
      li.appendChild(a);
      backlinksList.appendChild(li);
    }
  }

  // --- Tag cloud ---

  async function loadTagCloud() {
    const data = await apiFetch('/api/tags');
    if (!data) return;
    renderTagCloud(data);
  }

  function renderTagCloud(tags) {
    tagCloud.innerHTML = '';
    if (!tags || tags.length === 0) {
      tagCloud.innerHTML = '<span class="no-tags">No tags</span>';
      return;
    }

    // Find max count for sizing
    const maxCount = Math.max(...tags.map(function (t) { return t.count; }));

    for (const tag of tags) {
      const pill = document.createElement('span');
      pill.className = 'tag-pill';
      // Scale font size between 0.8em and 1.6em based on count
      const scale = maxCount > 1 ? 0.8 + (tag.count / maxCount) * 0.8 : 1;
      pill.style.fontSize = scale + 'em';
      pill.textContent = tag.name + ' (' + tag.count + ')';
      pill.dataset.tag = tag.name;
      pill.addEventListener('click', function () {
        searchInput.value = 'tag:' + tag.name;
        performSearch('tag:' + tag.name);
      });
      tagCloud.appendChild(pill);
    }
  }

  // --- Search ---

  let searchTimeout = null;

  function initSearch() {
    searchInput.addEventListener('input', function () {
      clearTimeout(searchTimeout);
      const query = searchInput.value.trim();
      if (query.length === 0) {
        searchResults.classList.add('hidden');
        searchResults.innerHTML = '';
        return;
      }
      // Debounce 300ms
      searchTimeout = setTimeout(function () {
        performSearch(query);
      }, 300);
    });

    // Close search results when clicking outside
    document.addEventListener('click', function (e) {
      if (!searchResults.contains(e.target) && e.target !== searchInput) {
        searchResults.classList.add('hidden');
      }
    });
  }

  async function performSearch(query) {
    const data = await apiFetch('/api/search?q=' + encodeURIComponent(query));
    if (!data) {
      searchResults.classList.add('hidden');
      return;
    }
    renderSearchResults(data);
  }

  function renderSearchResults(results) {
    searchResults.innerHTML = '';
    if (results.length === 0) {
      searchResults.innerHTML = '<div class="search-no-results">No results found</div>';
      searchResults.classList.remove('hidden');
      return;
    }

    for (const item of results) {
      const div = document.createElement('div');
      div.className = 'search-result-item';

      const title = document.createElement('div');
      title.className = 'search-result-title';
      title.textContent = item.title || item.path;
      div.appendChild(title);

      if (item.snippet) {
        const snippet = document.createElement('div');
        snippet.className = 'search-result-snippet';
        snippet.textContent = item.snippet;
        div.appendChild(snippet);
      }

      div.addEventListener('click', function () {
        searchResults.classList.add('hidden');
        searchInput.value = '';
        loadDocument(item.path);
      });

      searchResults.appendChild(div);
    }
    searchResults.classList.remove('hidden');
  }

  // --- Edit mode ---

  function initEditButtons() {
    btnEdit.addEventListener('click', function () {
      enterEditMode();
    });

    btnSave.addEventListener('click', async function () {
      await saveDocument();
    });

    btnCancel.addEventListener('click', function () {
      exitEditMode();
    });
  }

  function enterEditMode() {
    if (!currentDocPath) return;
    isEditing = true;
    editorTextarea.value = currentRawMarkdown;
    docContent.classList.add('hidden');
    editorArea.classList.remove('hidden');
    btnEdit.classList.add('hidden');
    btnSave.classList.remove('hidden');
    btnCancel.classList.remove('hidden');
  }

  function exitEditMode() {
    isEditing = false;
    docContent.classList.remove('hidden');
    editorArea.classList.add('hidden');
    btnSave.classList.add('hidden');
    btnCancel.classList.add('hidden');
    if (currentDocPath) {
      btnEdit.classList.remove('hidden');
    }
  }

  async function saveDocument() {
    if (!currentDocPath) return;
    const content = editorTextarea.value;
    const result = await apiFetch('/api/doc', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ path: currentDocPath, content: content })
    });

    if (result) {
      currentRawMarkdown = content;
      exitEditMode();
      // Re-render with new content
      let html = marked.parse(currentRawMarkdown);
      html = processWikilinks(html);
      docContent.innerHTML = html;
      docContent.querySelectorAll('.wikilink').forEach(function (el) {
        el.addEventListener('click', function (e) {
          e.preventDefault();
          loadDocument(el.dataset.target);
        });
      });
    }
  }

  // --- Init ---

  function init() {
    configureMarked();
    initSearch();
    initEditButtons();
    loadTree();
    loadTagCloud();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

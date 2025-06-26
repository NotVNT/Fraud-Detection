import type { NewsItem } from '../models/NewsItem';
import type { WantedPerson } from '../models/WantedPerson';

const MOCK_NEWS: NewsItem[] = [
  {
    source: 'ZNews',
    timeAgo: '1 giờ trước',
    title: 'Cảnh báo về chiêu lừa đảo mới trên mạng xã hội',
    imageUrl: 'https://znews-photo.zingcdn.me/w960/Uploaded/aohunkx/2024_06_26/thumb.jpg',
    articleUrl: 'https://znews.vn/article/1',
    tags: ['lừa đảo', 'mạng xã hội'],
    likes: 42,
    comments: 15,
    category: 'Thời sự',
    publishDate: new Date().toISOString()
  },
  {
    source: 'ZNews',
    timeAgo: '3 giờ trước',
    title: 'Truy tố nhóm lừa đảo chiếm đoạt hàng tỷ đồng',
    imageUrl: 'https://znews-photo.zingcdn.me/w960/Uploaded/mdf_drkydd/2024_04_18/lua_dao_mang.jpg',
    articleUrl: 'https://znews.vn/article/2',
    tags: ['pháp luật', 'lừa đảo'],
    likes: 78,
    comments: 32,
    category: 'Pháp luật',
    publishDate: new Date(Date.now() - 3600000).toISOString()
  },
  {
    source: 'ZNews',
    timeAgo: '1 ngày trước',
    title: 'Phương thức phát hiện và ngăn chặn hành vi lừa đảo trực tuyến',
    imageUrl: 'https://znews-photo.zingcdn.me/w960/Uploaded/znanug/2024_03_22/lua_dao_truc_tuyen.jpg',
    articleUrl: 'https://znews.vn/article/3',
    tags: ['hướng dẫn', 'an toàn'],
    likes: 105,
    comments: 47,
    category: 'Công nghệ',
    publishDate: new Date(Date.now() - 86400000).toISOString()
  },
  {
    source: 'ZNews',
    timeAgo: '2 ngày trước',
    title: 'Ngân hàng cảnh báo chiêu thức giả mạo gọi điện đánh cắp thông tin',
    imageUrl: 'https://znews-photo.zingcdn.me/w960/Uploaded/rohunzx/2024_05_01/ngan_hang_canh_bao.jpg',
    articleUrl: 'https://znews.vn/article/4',
    tags: ['ngân hàng', 'lừa đảo'],
    likes: 65,
    comments: 28,
    category: 'Tài chính',
    publishDate: new Date(Date.now() - 172800000).toISOString()
  }
];

const MOCK_WANTED: WantedPerson[] = [
  {
    id: 'TN001',
    name: 'Nguyễn Văn A',
    birthYear: '1985',
    address: 'Hà Nội',
    parentNames: 'Nguyễn Văn B, Trần Thị C',
    crime: 'Lừa đảo chiếm đoạt tài sản',
    decisionNumber: '01/2024/QĐ-CA',
    issuingUnit: 'Công an TP. Hà Nội',
    imageUrl: 'https://via.placeholder.com/150?text=NVA',
    detailUrl: 'https://truyna.bocongan.gov.vn/detail/1'
  },
  {
    id: 'TN002',
    name: 'Trần Văn D',
    birthYear: '1990',
    address: 'TP. Hồ Chí Minh',
    parentNames: 'Trần Văn E, Lê Thị F',
    crime: 'Giả mạo trong công tác',
    decisionNumber: '02/2024/QĐ-CA',
    issuingUnit: 'Công an TP. Hồ Chí Minh',
    imageUrl: 'https://via.placeholder.com/150?text=TVD',
    detailUrl: 'https://truyna.bocongan.gov.vn/detail/2'
  },
  {
    id: 'TN003',
    name: 'Lê Thị G',
    birthYear: '1988',
    address: 'Đà Nẵng',
    parentNames: 'Lê Văn H, Phạm Thị I',
    crime: 'Lừa đảo chiếm đoạt tài sản qua mạng',
    decisionNumber: '03/2024/QĐ-CA',
    issuingUnit: 'Công an TP. Đà Nẵng',
    imageUrl: 'https://via.placeholder.com/150?text=LTG',
    detailUrl: 'https://truyna.bocongan.gov.vn/detail/3'
  }
];

const API_BASE_URL = '/api';

export async function fetchNewsItems(page: number = 1, category: string = ''): Promise<NewsItem[]> {
  try {
    // In a real implementation, you would uncomment this code:
    // const response = await fetch(`${API_BASE_URL}/news-items?page=${page}&category=${category}`);
    // if (!response.ok) {
    //   throw new Error('Failed to fetch news items');
    // }
    // return await response.json();
    
    // For now, returning mock data
    return MOCK_NEWS;
  } catch (error) {
    console.error('Error fetching news items:', error);
    return [];
  }
}

export async function fetchWantedPersons(page: number = 1): Promise<WantedPerson[]> {
  try {
    // In a real implementation, you would uncomment this code:
    // const response = await fetch(`${API_BASE_URL}/wanted-list?page=${page}`);
    // if (!response.ok) {
    //   throw new Error('Failed to fetch wanted persons');
    // }
    // return await response.json();
    
    // For now, returning mock data
    return MOCK_WANTED;
  } catch (error) {
    console.error('Error fetching wanted persons:', error);
    return [];
  }
}

export function getNewsCategories(): string[] {
  return [
    'Thời sự',
    'Thế giới',
    'Kinh doanh',
    'Giải trí',
    'Thể thao',
    'Pháp luật',
    'Giáo dục',
    'Sức khỏe',
    'Đời sống',
    'Du lịch',
  ];
}

export function getWantedCategories(): string[] {
  return [
    'all',
    'financial',
    'cyber',
    'identity',
    'violent'
  ];
}

export function getWantedCategoryNames(): Record<string, string> {
  return {
    'all': 'Tất cả',
    'financial': 'Lừa đảo tài sản',
    'cyber': 'Tội phạm mạng',
    'identity': 'Giả danh',
    'violent': 'Tội phạm bạo lực'
  };
} 
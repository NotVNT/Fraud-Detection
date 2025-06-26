export interface NewsItem {
  source: string;
  timeAgo: string;
  title: string;
  imageUrl: string;
  articleUrl: string;
  tags: string[];
  likes: number;
  comments: number;
  category: string;
  publishDate: string; // Will be converted to Date when used
} 